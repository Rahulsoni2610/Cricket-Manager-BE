class Api::V1::TeamTournamentPlayersController < ApplicationController
  before_action :authenticate_user!

  # POST /api/v1/team_tournament_players
  def create
    TeamTournamentPlayer.transaction do
      TeamTournamentPlayer.where(
        team_id: params[:team_id],
        tournament_id: params[:tournament_id]
      ).destroy_all

      params[:player_ids].each do |player_id|
        TeamTournamentPlayer.create!(
          team_id: params[:team_id],
          tournament_id: params[:tournament_id],
          player_id: player_id
        )
      end
    end

    head :no_content
  end
end
