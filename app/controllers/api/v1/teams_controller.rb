module Api
  module V1
    class TeamsController < BaseController
      before_action :set_team, only: [:show, :update, :destroy, :players]

      def index
        @teams = Team.all
        render json: @teams
      end

      def show
        render json: @team
      end

      def create
        @team = current_user.teams.new(team_params)
        if @team.save
          render json: @team, status: :created
        else
          render json: { errors: @team.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @team.update(team_params)
          render json: @team
        else
          render json: { errors: @team.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        @team.destroy
        head :no_content
      end

      def players
        players = @team.players
          .joins(:team_tournament_players)
          .where(team_tournament_players: { tournament_id: params[:tournament_id] })
          .distinct

        render json: players
      end

      def roles
        if @team.update(
          captain_id: params[:captain_id],
          vice_captain_id: params[:vice_captain_id]
        )
          head :no_content
        else
          render json: { errors: @team.errors }, status: :unprocessable_entity
        end
      end

      private

      def set_team
        @team = Team.find(params[:id])
      end

      def team_params
        params.require(:team).permit(:name, :logo_url, :home_ground, :captain_id, :vice_captain_id)
      end
    end
  end
end
