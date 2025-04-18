module Api
  module V1
    class PlayersController < ApplicationController
      # before_action :set_player, only: [:show, :update, :destroy]

      # def index
      #   @players = Player.includes(:user, :teams, :tournaments)
      #                    .order(created_at: :desc)
      #                    .page(params[:page]).per(params[:per_page] || 20)

      #   render json: {
      #     players: @players.as_json(include: [:user, :teams, :tournaments], methods: [:age]),
      #     meta: pagination_meta(@players)
      #   }
      # end
      def index
        @players = Player.all
        render json: @players
      end

      # GET /api/v1/players/:id
      # def show
      #   render json: @player.as_json(include: [:user, :teams, :tournaments], methods: [:age])
      # end

      # # POST /api/v1/players
      # def create
      #   @player = Player.new(player_params)

      #   if @player.save
      #     render json: @player, status: :created
      #   else
      #     render json: { errors: @player.errors.full_messages }, status: :unprocessable_entity
      #   end
      # end

      # # PATCH/PUT /api/v1/players/:id
      # def update
      #   if @player.update(player_params)
      #     render json: @player
      #   else
      #     render json: { errors: @player.errors.full_messages }, status: :unprocessable_entity
      #   end
      # end

      # # DELETE /api/v1/players/:id
      # def destroy
      #   @player.destroy
      #   head :no_content
      # end

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
          team_ids: [],
          tournament_ids: []
        )
      end

      # def pagination_meta(collection)
      #   {
      #     current_page: collection.current_page,
      #     next_page: collection.next_page,
      #     prev_page: collection.prev_page,
      #     total_pages: collection.total_pages,
      #     total_count: collection.total_count
      #   }
      # end
    end
  end
end