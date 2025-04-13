class Api::V1::DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    render json: {
      team_count: current_user.teams.count,
      player_count: current_user.players.count,
      upcoming_matches: current_user.matches,
      welcome_message: "Welcome to your dashboard, #{current_user.username}"
    }
  end
end
