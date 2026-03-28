module Api
  module V1
    class OversController < BaseController
      before_action :set_match

      def create
        service = ::StartOverService.new(@match, params[:bowler_id])
        result = service.perform

        if result.success?
          render json: @match.reload.full_match_state, status: :created
        else
          render json: { error: result.error }, status: :unprocessable_entity
        end
      end

      private

      def set_match
        @match = Match.find(params[:match_id])
      end
    end
  end
end
