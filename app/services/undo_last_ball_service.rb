class UndoLastBallService
  def initialize(match)
    @match = match
  end

  def perform
    ActiveRecord::Base.transaction do
      @inning = @match.innings.last
      return ServiceResult.new(success: false, error: "No inning found") unless @inning

      # Find the last ball
      # We need to look at all overs, find the last one with balls, take the last ball.
      # Or simpler: @inning.balls.order(:created_at).last if balls allows direct access?
      # Schema: Ball belongs_to Over.
      # So we find the last over that has balls.
      last_over = @inning.overs.order(:over_number).select { |o| o.balls.any? }.last
      return ServiceResult.new(success: false, error: "No balls to undo") unless last_over

      @ball = last_over.balls.order(:ball_number).last

      revert_batsman_stats
      revert_mid_over_player_changes if @ball.is_wicket # Handle new batsman removal
      revert_bowler_stats
      revert_inning_totals

      # Restore Strike
      restore_strike

      # Destroy ball
      @ball.destroy!

      # If over becomes empty, we might want to adjust current_over logic?
      # But over object persists usually.
      # If it was the first ball of a new over, the over object stays but is empty.

      # Check match status
      if @match.status == 'completed'
        @match.status = 'live'
        @match.save!
      end

      ServiceResult.new(success: true)
    end
  rescue StandardError => e
    ServiceResult.new(success: false, error: e.message)
  end

  private

  def revert_batsman_stats
    @striker = @inning.batting_scorecards.find_by(player_id: @ball.batsman_id)
    raise StandardError, "Batsman scorecard not found" unless @striker

    runs_to_deduct = 0
    if @ball.legal_delivery?
      runs_to_deduct = @ball.runs
      @striker.balls -= 1
      @striker.fours -= 1 if @ball.runs == 4
      @striker.sixes -= 1 if @ball.runs == 6
    elsif @ball.extra_type == 'no_ball' && !@ball.is_bye
      runs_to_deduct = @ball.runs
      @striker.fours -= 1 if @ball.runs == 4
      @striker.sixes -= 1 if @ball.runs == 6
    elsif %w[wide bye leg_bye].include?(@ball.extra_type) || (@ball.extra_type == 'no_ball' && @ball.is_bye)
      @striker.balls -= 1 if @ball.legal_delivery?
    end

    @striker.runs -= runs_to_deduct

    if @ball.is_wicket
      @striker.how_out = nil
      @striker.fielder_id = nil
      @striker.bowler_id = nil
      @striker.is_striking = true # He is back
    end

    @striker.save!
  end

  def revert_mid_over_player_changes
    # If a new batsman was added AFTER this ball, delete him.
    # How to find?
    # The new batsman would have 0 balls, 0 runs, and be created_at > @ball.created_at
    # And be in this inning.
    recent_batsman = @inning.batting_scorecards.where('created_at > ?', @ball.created_at).last
    return unless recent_batsman

    recent_batsman.destroy!
  end

  def revert_bowler_stats
    bs = @inning.bowling_scorecards.find_by(player_id: @ball.bowler_id)
    return unless bs

    runs_conceded = 0
    runs_conceded += @ball.runs if @ball.legal_delivery? || %w[no_ball wide].include?(@ball.extra_type)

    # Penalties
    runs_conceded += 1 if %w[wide no_ball].include?(@ball.extra_type)

    bs.runs -= runs_conceded
    bs.wickets -= 1 if @ball.is_wicket && @ball.dismissal_type != 'run_out'
    bs.wides -= 1 if @ball.extra_type == 'wide'
    bs.no_balls -= 1 if @ball.extra_type == 'no_ball'

    # Re-calculate overs? Or just decrement?
    # Easier to decrement.
    # But overs is stored as float (e.g. 1.2).
    # If we undo a legal ball, we must reduce count.
    if @ball.legal_delivery?
      # Convert current overs to balls, sub 1, convert back
      overs_arr = bs.overs.to_s.split('.')
      total_legal_balls = (overs_arr[0].to_i * 6) + overs_arr[1].to_i
      total_legal_balls -= 1
      bs.overs = "#{total_legal_balls / 6}.#{total_legal_balls % 6}".to_f
    end

    bs.save!
  end

  def revert_inning_totals
    runs_to_deduct = @ball.runs
    runs_to_deduct += 1 if %w[wide no_ball].include?(@ball.extra_type)

    @inning.total_runs -= runs_to_deduct
    @inning.total_wickets -= 1 if @ball.is_wicket
    @inning.save!
  end

  def restore_strike
    # The guy who faced the ball (@ball.batsman) should be striking now.
    # The other active batsman should be non-striking.

    current_striker_card = @inning.batting_scorecards.find_by(player_id: @ball.batsman_id)
    # Find current active scorecard that is NOT the striker
    other_card = @inning.batting_scorecards.where(how_out: nil).where.not(player_id: @ball.batsman_id).first

    # If the undone ball was the last legal delivery of the over, strike would have swapped.
    # Undo should swap it back.
    over_legal_balls_before_undo = @ball.over.balls.where(extra_type: [nil, 'bye', 'leg_bye']).count
    current_striker_card, other_card = other_card, current_striker_card if @ball.legal_delivery? && (over_legal_balls_before_undo % 6).zero?

    current_striker_card&.update!(is_striking: true)
    other_card&.update!(is_striking: false)
  end
end
