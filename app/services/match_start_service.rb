class MatchStartService
  def initialize(match, params)
    @match = match
    @params = params
  end

  def perform
    validate_start_params!

    Match.transaction do
      assign_toss
      replace_match_players
      create_inning_if_missing
    end

    ServiceResult.new(success: true)
  rescue ActiveRecord::RecordInvalid => e
    ServiceResult.new(success: false, errors: e.record.errors.full_messages)
  rescue StandardError => e
    ServiceResult.new(success: false, errors: [e.message])
  end

  private

  def validate_start_params!
    raise StandardError, 'Both toss winner and toss choice must be provided' if @params[:toss_winner_id].blank? || @params[:toss_choice].blank?

    team1_ids = Array(@params[:team1_player_ids]).map(&:to_i).uniq
    team2_ids = Array(@params[:team2_player_ids]).map(&:to_i).uniq

    players_per_side = @match.players_per_side.to_i
    raise StandardError, 'Players per side must be set before starting the match' if players_per_side <= 0

    raise StandardError, 'Players must be selected for both teams' if team1_ids.empty? || team2_ids.empty?

    overlap = team1_ids & team2_ids
    raise StandardError, 'Same player cannot be selected for both teams' if overlap.any?

    raise StandardError, "Select exactly #{players_per_side} players per side" if team1_ids.length != players_per_side || team2_ids.length != players_per_side

    valid_team_ids = [@match.team1_id, @match.team2_id].map(&:to_i)
    toss_id = @params[:toss_winner_id].to_i

    raise StandardError, 'Toss winner must belong to this match' unless valid_team_ids.include?(toss_id)

    validate_team_players!(@match.team1, team1_ids)
    validate_team_players!(@match.team2, team2_ids)
  end

  def validate_team_players!(team, player_ids)
    team_player_ids = team.players.where(id: player_ids).pluck(:id)
    return unless team_player_ids.length != player_ids.length

    raise StandardError, "Selected players must belong to #{team.name}"
  end

  def assign_toss
    @match.toss_winner_id = @params[:toss_winner_id]
    @match.toss_decision = @params[:toss_choice]

    if @params[:toss_choice] == 'bat'
      @match.batting_team_id = @match.toss_winner_id
      @match.bowling_team_id = other_team_id(@match.toss_winner_id)
    else
      @match.bowling_team_id = @match.toss_winner_id
      @match.batting_team_id = other_team_id(@match.toss_winner_id)
    end

    @match.status = 'live'
    @match.save!
  end

  def other_team_id(team_id)
    team_id == @match.team1_id ? @match.team2_id : @match.team1_id
  end

  def replace_match_players
    @match.match_players.delete_all

    team1_ids = Array(@params[:team1_player_ids]).map(&:to_i).uniq
    team2_ids = Array(@params[:team2_player_ids]).map(&:to_i).uniq

    team1_ids.each do |player_id|
      MatchPlayer.create!(match: @match, team: @match.team1, player_id: player_id)
    end

    team2_ids.each do |player_id|
      MatchPlayer.create!(match: @match, team: @match.team2, player_id: player_id)
    end
  end

  def create_inning_if_missing
    return if @match.innings.exists?

    Inning.create!(
      match: @match,
      number: 1,
      batting_team_id: @match.batting_team_id,
      bowling_team_id: @match.bowling_team_id,
      total_overs: @match.total_overs || 20
    )
  end
end
