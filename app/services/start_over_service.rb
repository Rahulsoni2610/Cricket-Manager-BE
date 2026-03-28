class StartOverService
  def initialize(match, bowler_id)
    @match = match
    @bowler_id = bowler_id
  end

  def perform
    ActiveRecord::Base.transaction do
      return ServiceResult.new(success: false, error: "Match is already completed") if @match.status == 'completed'

      # Determine next over number
      current_inning = @match.innings.last
      return ServiceResult.new(success: false, error: "Inning not initialized") unless current_inning

      return ServiceResult.new(success: false, error: "Inning complete. Initialize next inning.") if inning_complete?(current_inning)

      last_over = current_inning.overs.order(:over_number).last

      # Validation: Ensure previous over is actually done (legal deliveries only)
      if last_over
        legal_balls = last_over.balls.where(extra_type: [nil, 'bye', 'leg_bye']).count
        return ServiceResult.new(success: false, error: "Previous over is not complete") if legal_balls < 6
      end

      next_over_number = last_over ? last_over.over_number + 1 : 1

      # Validation: Check match over limit
      return ServiceResult.new(success: false, error: "Match over limit reached") if @match.total_overs.present? && next_over_number > @match.total_overs

      # Create the over
      over = current_inning.overs.create!(
        over_number: next_over_number,
        bowler_id: @bowler_id
      )

      ServiceResult.new(success: true, over: over)
    end
  rescue StandardError => e
    ServiceResult.new(success: false, error: e.message)
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
