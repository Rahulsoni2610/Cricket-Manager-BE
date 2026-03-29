class MatchSetupService
  # Params: user, params (team1_id, team2_id, overs, venue, match_type, toss_winner_id, batting_team_id)
  def initialize(user, params)
    @user = user
    @params = params
  end

  def perform
    Match.transaction do
      validate_teams!
      validate_overs!
      validate_toss_params!

      match_params = @params.except(:toss_winner_id, :batting_team_id, :overs)
      match_params[:total_overs] = @params[:overs] || 20

      match = Match.new(match_params)
      match.user = @user
      match.status = 'scheduled'
      match.match_date ||= Time.current

      match.save!

      match
    end
  rescue ActiveRecord::RecordInvalid => e
    ServiceResult.new(success: false, errors: e.record.errors.full_messages)
  rescue StandardError => e
    ServiceResult.new(success: false, errors: [e.message])
  end

  private

  def validate_teams!
    return unless @params[:team1_id] == @params[:team2_id]

    raise StandardError, "Teams must be different"
  end

  def validate_overs!
    overs = @params[:overs].to_i
    return unless overs <= 0

    raise StandardError, "Overs must be greater than 0"
  end

  def create_inning(match, number, batting_id, bowling_id)
    Inning.create!(
      match: match,
      number: number,
      batting_team_id: batting_id,
      bowling_team_id: bowling_id,
      total_overs: match.total_overs || 20
    )
  end

  def validate_toss_params!
    return if @params[:toss_winner_id].blank? && @params[:batting_team_id].blank?

    raise StandardError, "Both toss winner and batting team must be provided" if @params[:toss_winner_id].blank? || @params[:batting_team_id].blank?

    valid_team_ids = [@params[:team1_id], @params[:team2_id]].map(&:to_i)
    toss_id = @params[:toss_winner_id].to_i
    batting_id = @params[:batting_team_id].to_i

    return if valid_team_ids.include?(toss_id) && valid_team_ids.include?(batting_id)

    raise StandardError, "Toss winner and batting team must belong to this match"
  end
end
