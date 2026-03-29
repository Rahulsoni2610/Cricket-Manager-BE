class InitializeInningService
  def initialize(match, params)
    @match = match
    @params = params
    # params: striker_id, non_striker_id, bowler_id
  end

  def perform
    ActiveRecord::Base.transaction do
      inning = @match.innings.order(:number).last

      # Ensure inning exists (it should have been created in MatchSetup)
      return ServiceResult.new(success: false, error: "Inning not found") unless inning

      # Clear existing scorecards if any (restart scenario)
      inning.batting_scorecards.destroy_all
      inning.bowling_scorecards.destroy_all
      inning.overs.destroy_all

      # Create Batting Scorecards
      # Striker
      inning.batting_scorecards.create!(
        player_id: @params[:striker_id],
        batting_position: 1,
        is_striking: true,
        runs: 0,
        balls: 0,
        fours: 0,
        sixes: 0
      )

      # Non-Striker
      inning.batting_scorecards.create!(
        player_id: @params[:non_striker_id],
        batting_position: 2,
        is_striking: false,
        runs: 0,
        balls: 0,
        fours: 0,
        sixes: 0
      )

      # Create Bowling Scorecard
      inning.bowling_scorecards.create!(
        player_id: @params[:bowler_id],
        runs: 0,
        wickets: 0,
        overs: 0,
        maidens: 0,
        wides: 0,
        no_balls: 0
      )

      # Create First Over
      inning.overs.create!(
        over_number: 1,
        bowler_id: @params[:bowler_id]
      )

      # Match is now in progress
      @match.update!(status: 'live')

      ServiceResult.new(success: true)
    end
  rescue StandardError => e
    ServiceResult.new(success: false, error: e.message)
  end
end
