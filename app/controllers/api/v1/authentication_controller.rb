module Api
  module V1
    class AuthenticationController < Api::V1::BaseController
      skip_before_action :authenticate_user!, only: [:login]

      def login
        user = User.find_for_database_authentication(email: params[:email])
        if user&.valid_password?(params[:password])
          render json: payload(user)
        else
          render json: { errors: ['Invalid Email/Password'] }, status: :unauthorized
        end
      end

      def logout
        current_user.jwt_denylist.create!(jti: decoded_token[:jti], exp: Time.at(decoded_token[:exp]))
        render json: { message: 'Logged out successfully' }
      end

      private

      def payload(user)
        return nil unless user && user.id
        {
          auth_token: generate_token(user),
          user: { id: user.id, email: user.email, username: user.username }
        }
      end

      def generate_token(user)
        Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first
      end

      def decoded_token
        @decoded_token ||= Warden::JWTAuth::TokenDecoder.new.call(request.headers['Authorization'].split.last)
      end
    end
  end
end
