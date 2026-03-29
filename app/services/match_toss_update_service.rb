class MatchTossUpdateService
  def initialize(match, params)
    @match = match
    @params = params
  end

  def perform
    validate_toss_params!

    @match.toss_winner_id = @params[:toss_winner_id]
    @match.batting_team_id = @params[:batting_team_id]
    @match.bowling_team_id = bowling_team_id
    @match.toss_decision = @match.toss_winner_id == @match.batting_team_id ? 'bat' : 'bowl'
    @match.status = 'live'

    Match.transaction do
      @match.save!
      create_inning_if_missing
    end

    ServiceResult.new(success: true)
  rescue ActiveRecord::RecordInvalid => e
    ServiceResult.new(success: false, errors: e.record.errors.full_messages)
  rescue StandardError => e
    ServiceResult.new(success: false, errors: [e.message])
  end

  private

  def validate_toss_params!
    raise StandardError, 'Both toss winner and batting team must be provided' if @params[:toss_winner_id].blank? || @params[:batting_team_id].blank?

    valid_team_ids = [@match.team1_id, @match.team2_id].map(&:to_i)
    toss_id = @params[:toss_winner_id].to_i
    batting_id = @params[:batting_team_id].to_i

    return if valid_team_ids.include?(toss_id) && valid_team_ids.include?(batting_id)

    raise StandardError, 'Toss winner and batting team must belong to this match'
  end

  def bowling_team_id
    @match.batting_team_id == @match.team1_id ? @match.team2_id : @match.team1_id
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
