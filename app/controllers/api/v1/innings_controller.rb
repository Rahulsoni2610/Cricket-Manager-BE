module Api
  module V1
    class InningsController < BaseController
      before_action :set_match
      before_action :set_inning

      def add_batsman
        return render json: { error: "Inning not found" }, status: :not_found if @inning.nil?

        service = ::AddBatsmanService.new(@inning, add_batsman_params)
        result = service.perform

        if result.success?
          render json: @match.reload.full_match_state, status: :ok
        else
          render json: { error: result.error }, status: :unprocessable_entity
        end
      end

      private

      def set_match
        @match = Match.find(params[:match_id])
      end

      def set_inning
        @inning = @match.innings.find(params[:id])
      end

      def add_batsman_params
        params.permit(:player_id)
      end
    end
  end
end
