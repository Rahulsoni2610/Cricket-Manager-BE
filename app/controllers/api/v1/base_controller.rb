module Api
  module V1
    class BaseController < ActionController::API
      before_action :authenticate_user!
      include Pundit::Authorization

      rescue_from ActiveRecord::RecordNotFound, with: :not_found
      rescue_from Pundit::NotAuthorizedError, with: :unauthorized

      private

      def not_found
        render json: { error: 'Record not found' }, status: :not_found
      end

      def unauthorized
        render json: { error: 'Unauthorized' }, status: :unauthorized
      end
    end
  end
end
