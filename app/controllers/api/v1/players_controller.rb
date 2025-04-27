module Api
  module V1
    class PlayersController < ApplicationController
      before_action :set_player, only: [:show, :update, :destroy]

      def index
        @players = Player.where("first_name ILIKE :search OR last_name ILIKE :search", search: "%#{params[:search]}%")
        render json: @players
      end

      def show
        render json: @player
      end

      def create
        @player = current_user.players.new(player_params)

        if @player.save
          render json: @player, status: :created
        else
          render json: { errors: @player.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @player.update(player_params)
          render json: @player
        else
          render json: { errors: @player.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @player.destroy
        render json: @player, status: :ok
      end

      def available
        @players = Player.where.not(
          id: TeamTournamentPlayer.where(
            team_id: params[:team_id],
            tournament_id: params[:tournament_id]
          )
        )

        render json: @players
      end

      private

      def set_player
        @player = Player.find(params[:id])
      end

      def player_params
        params.require(:player).permit(
          :user_id,
          :first_name,
          :last_name,
          :date_of_birth,
          :batting_style,
          :bowling_style,
          :role,
          :picture
        )
      end
    end
  end
end
