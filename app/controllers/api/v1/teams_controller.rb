module Api
  module V1
    class TeamsController < BaseController
      before_action :set_team, only: [:show, :update, :destroy]

      def index
        @teams = Team.all
        render json: @teams
      end

      def show
        render json: @team
      end

      def create
        @team = current_user.teams.new(team_params)
        authorize @team

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

      private

      def set_team
        @team = Team.find(params[:id])
        authorize @team
      end

      def team_params
        params.require(:team).permit(:name, :logo_url, :home_ground)
      end
    end
  end
end
