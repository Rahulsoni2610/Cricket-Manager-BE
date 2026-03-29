class MatchStateSerializer
  def initialize(match)
    @match = match
  end

  def as_json
    state = build_base_state

    current_inning = @match.innings.order(:number).last
    if current_inning
      enrich_with_inning_details(state, current_inning)
      state[:inning_complete] = inning_complete?(current_inning)
    end

    state
  end

  private

  def build_base_state
    {
      id: @match.id,
      status: @match.status,
      result: @match.result,
      winning_margin: @match.winning_margin,
      winning_team: @match.winning_team&.as_json(only: [:id, :name]),
      current_inning_id: @match.innings.order(:number).last&.id,
      total_overs: @match.total_overs.to_i.positive? ? @match.total_overs : 20,
      venue: @match.venue,
      batting_team: @match.batting_team&.as_json(only: [:id, :name]),
      bowling_team: @match.bowling_team&.as_json(only: [:id, :name]),
      match_header: {
        score: nil,
        wickets: nil,
        overs: nil,
        balls: nil,
        run_rate: nil
      },
      chase: nil,
      current_over: [],
      batsmen: [],
      bowler: nil,
      new_batsman_required: false,
      out_player_ids: [],
      playing_xi: {
        team1: [],
        team2: []
      },
      innings: []
    }
  end

  def enrich_with_inning_details(state, current_inning)
    add_current_over_data(state, current_inning)
    add_batsmen_data(state, current_inning)
    add_match_header_stats(state, current_inning)
    add_innings_scorecard(state)
    add_chase_context(state, current_inning)
    add_playing_xi(state)

    state[:out_player_ids] = current_inning.batting_scorecards.where.not(how_out: nil).pluck(:player_id)
  end

  def add_current_over_data(state, current_inning)
    current_over_obj = current_inning.overs.order(:over_number).last
    return unless current_over_obj

    state[:current_over] = current_over_obj.balls.order(:ball_number).map do |b|
      serialize_ball(b)
    end

    state[:bowler] = serialize_bowler(current_over_obj.bowler, current_inning)

    # Explicit flag for frontend to know if over is finished
    # Use blank? to capture nil or empty strings
    legal_balls_count = current_over_obj.balls.select { |b| b.extra_type.blank? || %w[bye leg_bye].include?(b.extra_type) }.count
    state[:over_complete] = legal_balls_count >= 6
  end

  def serialize_ball(ball)
    if ball.is_wicket
      'W'
    elsif ball.extra_type.present?
      case ball.extra_type
      when 'wide'
        ball.runs.zero? ? 'wd' : "#{ball.runs + 1}wd"
      when 'no_ball'
        ball.runs.zero? ? 'nb' : "#{ball.runs + 1}nb"
      when 'bye'
        "#{ball.runs}b"
      when 'leg_bye'
        "#{ball.runs}lb"
      else
        ball.runs
      end
    else
      ball.runs
    end
  end

  def serialize_bowler(bowler, current_inning)
    return nil unless bowler

    {
      id: bowler.id,
      name: "#{bowler.first_name} #{bowler.last_name}",
      stats: current_inning.bowling_scorecards.find_by(player_id: bowler.id)&.as_json(only: [:overs, :runs, :wickets, :maidens])
    }
  end

  def add_batsmen_data(state, current_inning)
    active_scorecards = current_inning.batting_scorecards.where(how_out: nil).limit(2)
    state[:batsmen] = active_scorecards.map do |bs|
      {
        id: bs.player_id,
        name: "#{bs.player.first_name} #{bs.player.last_name}",
        runs: bs.runs,
        balls: bs.balls,
        on_strike: bs.is_striking
      }
    end

    # New Batsman Required Logic
    # Check if inning has started (current_over_obj present check implicitly handled by calling this only if current_inning exists? No.)
    # We need to check if match is "live" essentially.
    current_over_obj = current_inning.overs.order(:over_number).last
    max_wickets = [(@match.players_per_side.presence || 11).to_i - 1, 0].max
    state[:new_batsman_required] = active_scorecards.count < 2 && current_inning.total_wickets < max_wickets && current_over_obj.present?
  end

  def add_match_header_stats(state, current_inning)
    legal_balls = current_inning.balls.where(extra_type: [nil, 'bye', 'leg_bye']).count
    overs_completed = (legal_balls / 6).floor
    balls_remaining = legal_balls % 6

    state[:match_header] = {
      score: current_inning.total_runs,
      wickets: current_inning.total_wickets,
      overs: overs_completed,
      balls: balls_remaining,
      run_rate: legal_balls.positive? ? (current_inning.total_runs / (legal_balls / 6.0)).round(2) : 0
    }
  end

  def add_chase_context(state, current_inning)
    return if @match.status == 'completed'
    return unless current_inning.number.to_i == 2

    first_inning = @match.innings.find_by(number: 1)
    return unless first_inning

    total_balls = current_inning.total_overs.to_i * 6
    legal_balls = current_inning.balls.where(extra_type: [nil, 'bye', 'leg_bye']).count

    target = first_inning.total_runs.to_i + 1
    runs_remaining = target - current_inning.total_runs.to_i
    balls_remaining = total_balls - legal_balls

    return if runs_remaining <= 0

    runs_remaining = [runs_remaining, 0].max
    balls_remaining = [balls_remaining, 0].max

    required_run_rate = if balls_remaining.positive?
                          (runs_remaining / (balls_remaining / 6.0)).round(2)
                        else
                          0
                        end

    state[:chase] = {
      target: target,
      runs_remaining: runs_remaining,
      balls_remaining: balls_remaining,
      required_run_rate: required_run_rate
    }
  end

  def add_innings_scorecard(state)
    state[:innings] = @match.innings.order(:number).map do |inning|
      legal_balls = inning.balls.where(extra_type: [nil, 'bye', 'leg_bye']).count
      overs_completed = (legal_balls / 6).floor
      balls_remaining = legal_balls % 6

      batting_cards = inning.batting_scorecards.includes(:player, :bowler, :fielder).order(:batting_position).map do |bs|
        {
          player_id: bs.player_id,
          name: "#{bs.player.first_name} #{bs.player.last_name}",
          runs: bs.runs,
          balls: bs.balls,
          fours: bs.fours,
          sixes: bs.sixes,
          how_out: bs.how_out,
          is_striking: bs.is_striking,
          bowler: bs.bowler ? "#{bs.bowler.first_name} #{bs.bowler.last_name}" : nil,
          fielder: bs.fielder ? "#{bs.fielder.first_name} #{bs.fielder.last_name}" : nil
        }
      end

      bowling_cards = inning.bowling_scorecards.includes(:player).map do |bs|
        {
          player_id: bs.player_id,
          name: "#{bs.player.first_name} #{bs.player.last_name}",
          overs: bs.overs,
          maidens: bs.maidens,
          runs: bs.runs,
          wickets: bs.wickets,
          wides: bs.wides,
          no_balls: bs.no_balls
        }
      end

      {
        id: inning.id,
        number: inning.number,
        batting_team: inning.batting_team&.as_json(only: [:id, :name]),
        bowling_team: inning.bowling_team&.as_json(only: [:id, :name]),
        total_runs: inning.total_runs,
        total_wickets: inning.total_wickets,
        overs: overs_completed,
        balls: balls_remaining,
        batting_scorecards: batting_cards,
        bowling_scorecards: bowling_cards
      }
    end
  end

  def add_playing_xi(state)
    return unless @match.match_players.exists?

    grouped = @match.match_players.includes(:player, :team).group_by(&:team_id)

    state[:playing_xi][:team1] = (grouped[@match.team1_id] || []).map do |mp|
      {
        id: mp.player_id,
        name: "#{mp.player.first_name} #{mp.player.last_name}".strip
      }
    end

    state[:playing_xi][:team2] = (grouped[@match.team2_id] || []).map do |mp|
      {
        id: mp.player_id,
        name: "#{mp.player.first_name} #{mp.player.last_name}".strip
      }
    end
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
end
