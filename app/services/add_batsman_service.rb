class AddBatsmanService
  def initialize(inning, params)
    @inning = inning
    @params = params
    # params: player_id
  end

  def perform
    ActiveRecord::Base.transaction do
      # Validate: Ensure we need a batsman
      active_batsmen_count = @inning.batting_scorecards.where(how_out: nil).count
      return ServiceResult.new(success: false, error: "Batsmen limit reached. Two batsmen are already on the crease.") if active_batsmen_count >= 2

      # Determine batting position (max + 1)
      last_position = @inning.batting_scorecards.maximum(:batting_position) || 0
      next_position = last_position + 1

      # Determine if he is striking?
      # If the other active batsman is NOT striking, then this one MUST be striking (unless non-striker got out?)
      # Logic:
      # If Striker got Out -> New batsman is Striker (usually, unless cross happened, but keeping it simple: New man takes strike)
      # If Non-Striker got Out -> New batsman is Non-Striker

      # Let's check the current active batsman's status
      other_batsman = @inning.batting_scorecards.find_by(how_out: nil)
      is_on_strike = if other_batsman
                       # If the other guy is on strike, new guy is non-striker
                       # If the other guy is NOT on strike, new guy IS striking
                       !other_batsman.is_striking
                     else
                       # If NO active batsman (shouldn't happen here if active_count < 2 check passed, but implies 1 or 0)
                       # If 0 active (opening?), then striking = true for first, false for second.
                       # But this service is for "Adding" one.
                       # Fallback:
                       true
                     end

      @inning.batting_scorecards.create!(
        player_id: @params[:player_id],
        batting_position: next_position,
        is_striking: is_on_strike,
        runs: 0,
        balls: 0,
        fours: 0,
        sixes: 0
      )

      ServiceResult.new(success: true)
    end
  rescue StandardError => e
    ServiceResult.new(success: false, error: e.message)
  end
end
