class MatchScoringService
  def initialize(match_id, params)
    @match = Match.find(match_id)
    @params = params
    # params expected: runs, extra_type, is_wicket, batsman_id, bowler_id, how_out, fielder_id, new_batsman_id, is_bye
  end

  def perform
    ActiveRecord::Base.transaction do
      @match.lock!
      record_ball
      update_scorecards
      update_inning_totals
      add_new_batsman if @params[:is_wicket] && @params[:new_batsman_id].present?
      handle_match_state

      ServiceResult.new(success: true, match: @match, ball: @ball)
    end
  rescue StandardError => e
    ServiceResult.new(success: false, error: e.message)
  end

  private

  def record_ball
    @inning = @match.innings.find_by(number: current_inning_number)
    raise StandardError, "Inning not initialized" unless @inning

    # Identify current striker - TRUST THE DATABASE for who is striking
    @striker = @inning.batting_scorecards.find_by(is_striking: true, how_out: nil)
    @non_striker = @inning.batting_scorecards.where(how_out: nil, is_striking: false).first

    # Fallback if no striker (shouldn't happen if initialized properly)
    unless @striker
      # Attempt to recover or error
      raise StandardError, "No active striker found"
    end

    # Use the database striker ID instead of params if we trust backend logic
    # But for now, we can validate or just overwrite params[:batsman_id]
    @params[:batsman_id] = @striker.player_id

    # Get or create current over
    # Get current over - MUST EXIST (Created by OversController)
    @over = @inning.overs.find_by(over_number: current_over_number)

    raise StandardError, "Over not started. Please select a bowler." unless @over

    # Create the ball
    @ball = @over.balls.create!(
      ball_number: calculate_ball_number,
      runs: @params[:runs].to_i,
      extra_type: @params[:extra_type],
      is_wicket: @params[:is_wicket] || false,
      is_bye: @params[:is_bye] || false,
      batsman_id: @striker.player_id,
      bowler_id: @params[:bowler_id],
      dismissal_type: @params[:how_out],
      fielder_id: @params[:fielder_id]
    )
  end

  def update_scorecards
    # Update Batman Scorecard
    # Batsman gets runs if it's a legal delivery OR a No Ball (runs off bat).
    # Batsman does NOT get runs for Wides, Byes, or Leg Byes.
    # ALSO: If No Ball + Byes, Batsman does NOT get runs.

    runs_for_batsman = false
    if @ball.legal_delivery?
      runs_for_batsman = true
    elsif @ball.extra_type == 'no_ball'
      runs_for_batsman = !@ball.is_bye
    end

    if runs_for_batsman
      @striker.runs += @ball.runs
      @striker.balls += 1 if @ball.legal_delivery?
      @striker.fours += 1 if @ball.runs == 4
      @striker.sixes += 1 if @ball.runs == 6
      if @ball.is_wicket
        @striker.how_out = @params[:how_out] || "Out"
        @striker.fielder_id = @params[:fielder_id]
        @striker.bowler_id = @ball.bowler_id unless @params[:how_out] == 'run_out'

        @striker.is_striking = false
        # Next batsman logic is separated, frontend asks for next batsman or we auto-pick?
        # For now, just mark him out. New batsman will need to be "Initialized" or "Next"
      else
        # Strike Rotation Logic
        # Rotate if runs are odd
        total_runs_ran = @ball.runs
        rotate_strike if total_runs_ran.odd?
      end

      @striker.save!
      @non_striker&.save! # Save incase rotated
    elsif %w[wide bye leg_bye].include?(@ball.extra_type) || (@ball.extra_type == 'no_ball' && @ball.is_bye)
      # For wides/byes/legbyes (and NB+Byes), runs don't go to batsman.
      # But if runs ran is odd, rotate strike.
      total_runs_ran = @ball.runs
      rotate_strike if total_runs_ran.odd?
      @striker.balls += 1 if @ball.legal_delivery?
      @striker.save!
      @non_striker&.save!
    end

    # Update Bowler Scorecard
    bs = @inning.bowling_scorecards.find_or_initialize_by(player_id: @ball.bowler_id)

    # Bowler Conceded Calculation:
    # 1. Runs off Bat (Legal or No Ball) -> counted.
    # 2. Wides -> Penalty (1) + Runs ran -> counted.
    # 3. No Ball -> Penalty (1) + Runs off bat -> counted.
    # 4. Byes / Leg Byes -> NOT counted against bowler.

    runs_conceded = 0
    runs_conceded += @ball.runs if @ball.legal_delivery? || %w[no_ball wide].include?(@ball.extra_type)

    # Add Penalties
    runs_conceded += 1 if %w[wide no_ball].include?(@ball.extra_type)

    bs.runs = (bs.runs || 0) + runs_conceded
    bs.wickets = (bs.wickets || 0) + 1 if @ball.is_wicket && @params[:how_out] != 'run_out'

    # Overs should reflect total legal balls bowled in the innings by this bowler
    legal_balls_for_bowler = @inning.balls.where(bowler_id: @ball.bowler_id, extra_type: [nil, 'bye', 'leg_bye']).count
    bs.overs = "#{legal_balls_for_bowler / 6}.#{legal_balls_for_bowler % 6}".to_f

    bs.wides = (bs.wides || 0) + 1 if @ball.extra_type == 'wide'
    bs.no_balls = (bs.no_balls || 0) + 1 if @ball.extra_type == 'no_ball'
    bs.save!
  end

  def update_inning_totals
    runs_to_add = @ball.runs
    # Extras add 1 run only for wides and no balls
    runs_to_add += 1 if %w[wide no_ball].include?(@ball.extra_type)

    @inning.total_runs += runs_to_add
    @inning.total_wickets += 1 if @ball.is_wicket
    @inning.save!
  end

  def add_new_batsman
    service = ::AddBatsmanService.new(@inning, { player_id: @params[:new_batsman_id] })
    result = service.perform
    return if result.success?

    raise StandardError, "Failed to add new batsman: #{result.error}"
  end

  def handle_match_state
    # Check for over completion
    legal_balls_in_over = @over.balls.select(&:legal_delivery?).count
    if legal_balls_in_over >= 6
      # End of over - SWAP STRIKE
      # But only if not all out
      rotate_strike if @striker && @non_striker && @striker.how_out.nil? && @non_striker.how_out.nil?

      # Persist changes
      @striker&.save!
      @non_striker&.save!
    end

    # If we're in second innings and the chase is complete, end match immediately
    if second_innings_chase_complete?
      set_result_for_chase_win!
      return
    end

    # Check for inning completion
    return unless inning_complete?(@inning)

    if @match.innings.count < 2
      create_next_inning!
      @match.update!(status: 'paused')
    else
      set_result_for_completed_match!
    end
  end

  def create_next_inning!
    next_number = @inning.number + 1
    next_batting_id = @inning.bowling_team_id
    next_bowling_id = @inning.batting_team_id

    Inning.create!(
      match: @match,
      number: next_number,
      batting_team_id: next_batting_id,
      bowling_team_id: next_bowling_id,
      total_overs: @inning.total_overs
    )

    @match.update!(
      batting_team_id: next_batting_id,
      bowling_team_id: next_bowling_id
    )
  end

  def second_innings_chase_complete?
    return false unless @inning.number.to_i == 2

    first_inning = @match.innings.find_by(number: 1)
    return false unless first_inning

    target = first_inning.total_runs.to_i + 1
    @inning.total_runs.to_i >= target
  end

  def set_result_for_chase_win!
    max_wickets = [(@match.players_per_side.presence || 11).to_i - 1, 0].max
    winning_wickets = max_wickets - @inning.total_wickets.to_i
    @match.update!(
      status: 'completed',
      winning_team_id: @inning.batting_team_id,
      winning_margin: "#{winning_wickets} wickets",
      result: 'won'
    )
  end

  def set_result_for_completed_match!
    first_inning = @match.innings.find_by(number: 1)
    return @match.update!(status: 'completed') unless first_inning

    if @inning.total_runs.to_i == first_inning.total_runs.to_i
      @match.update!(
        status: 'completed',
        result: 'tied',
        winning_team_id: nil,
        winning_margin: nil
      )
    elsif @inning.total_runs.to_i < first_inning.total_runs.to_i
      runs_margin = first_inning.total_runs.to_i - @inning.total_runs.to_i
      @match.update!(
        status: 'completed',
        winning_team_id: first_inning.batting_team_id,
        winning_margin: "#{runs_margin} runs",
        result: 'won'
      )
    else
      set_result_for_chase_win!
    end
  end

  def rotate_strike
    return unless @striker && @non_striker

    # Swap is_striking flags
    @striker.is_striking = false
    @non_striker.is_striking = true

    # Swap variables for local context if needed further down
    @striker, @non_striker = @non_striker, @striker
  end

  def current_inning_number
    innings = @match.innings.order(:number)
    return 1 if innings.empty?

    incomplete = innings.find { |inn| !inning_complete?(inn) }
    (incomplete || innings.last).number
  end

  def inning_complete?(inning)
    return true if inning.declared

    max_wickets = [(@match.players_per_side.presence || 11).to_i - 1, 0].max
    return true if inning.total_wickets >= max_wickets

    total_overs = inning.total_overs.to_i
    return false if total_overs <= 0

    legal_balls = inning.balls.where(extra_type: [nil, 'bye', 'leg_bye']).count
    legal_balls >= total_overs * 6
  end

  def current_over_number
    # Getting the last over number or 0
    last_over = @inning.overs.order(:over_number).last
    return 0 unless last_over

    # If last over is full (6 legal balls), start next
    legal_balls = last_over.balls.select(&:legal_delivery?).count
    if legal_balls >= 6
      last_over.over_number + 1
    else
      last_over.over_number
    end
  end

  def calculate_ball_number
    # Balls in current over + 1 (lock the over row for concurrency safety)
    @over.lock!
    @over.balls.count + 1
  end
end
