module Api
  module V1
    class MatchesController < ApplicationController
      before_action :authenticate_user! # Assuming generic auth module
      before_action :set_match, only: [:show, :update, :start, :score, :initialize_inning, :undo]

      def index
        @matches = current_user.matches.includes(:team1, :team2, :innings).order(created_at: :desc)
        render json: @matches.map { |match| match_summary(match) }
      end

      def create
        service = ::MatchSetupService.new(current_user, match_params)
        result = service.perform

        if result.is_a?(Match)
          render json: result, status: :created
        else
          render json: { errors: result.errors }, status: :unprocessable_entity
        end
      end

      def show
        render json: @match.full_match_state
      end

      def update
        update_params = match_params.except(:toss_winner_id, :batting_team_id, :overs)
        update_params[:total_overs] = match_params[:overs] if match_params[:overs].present?

        if @match.update(update_params)
          render json: @match, status: :ok
        else
          render json: { errors: @match.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def start
        service = ::MatchStartService.new(@match, start_params)
        result = service.perform

        if result.success?
          render json: @match.reload.full_match_state, status: :ok
        else
          render json: { errors: result.errors }, status: :unprocessable_entity
        end
      end

      def score
        service = ::MatchScoringService.new(@match.id, scoring_params)
        result = service.perform

        if result.success?
          render json: @match.reload.full_match_state, status: :ok
        else
          render json: { error: result.error }, status: :unprocessable_entity
        end
      end

      def initialize_inning
        service = ::InitializeInningService.new(@match, initialize_inning_params)
        result = service.perform

        if result.success?
          render json: @match.reload.full_match_state, status: :ok
        else
          render json: { error: result.error }, status: :unprocessable_entity
        end
      end

      def undo
        service = ::UndoLastBallService.new(@match)
        result = service.perform

        if result.success?
          render json: @match.reload.full_match_state, status: :ok
        else
          render json: { error: result.error }, status: :unprocessable_entity
        end
      end

      private

      def set_match
        @match = Match.find(params[:id])
      end

      def match_params
        params.require(:match).permit(
          :id,
          :team1_id,
          :team2_id,
          :overs,
          :venue,
          :match_type,
          :toss_winner_id,
          :batting_team_id,
          :match_name,
          :players_per_side,
          :match_date,
          match: {}
        )
      end

      def scoring_params
        params.permit(:runs, :extra_type, :is_wicket, :batsman_id, :bowler_id, :how_out, :fielder_id, :new_batsman_id, :is_bye)
      end

      def initialize_inning_params
        params.permit(:striker_id, :non_striker_id, :bowler_id)
      end

      def start_params
        params.require(:match).permit(
          :toss_winner_id,
          :toss_choice,
          team1_player_ids: [],
          team2_player_ids: []
        )
      end

      def match_summary(match)
        team1_score = innings_score(match, match.team1_id)
        team2_score = innings_score(match, match.team2_id)

        {
          id: match.id,
          status: match.status,
          team1_id: match.team1_id,
          team2_id: match.team2_id,
          team1_name: match.team1&.name,
          team2_name: match.team2&.name,
          match_date: match.match_date,
          venue: match.venue,
          match_type: match.match_type,
          players_per_side: match.players_per_side,
          team1_score: team1_score,
          team2_score: team2_score
        }
      end

      def innings_score(match, team_id)
        inning = match.innings.find { |inn| inn.batting_team_id == team_id }
        return nil unless inning

        "#{inning.total_runs}/#{inning.total_wickets}"
      end
    end
  end
end
