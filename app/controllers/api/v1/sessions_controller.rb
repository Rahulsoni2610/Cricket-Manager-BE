module Api
  module V1
    class SessionsController < Devise::SessionsController
      respond_to :json

      private

      def respond_with(resource, _opts = {})
        render json: {
          status: { code: 200, message: 'Logged in successfully' },
          data: resource.as_json(only: [:id, :email, :username]),
          jwt: request.env['warden-jwt_auth.token']
        }
      end

      def respond_to_on_destroy
        head :ok
      end
    end
  end
end
