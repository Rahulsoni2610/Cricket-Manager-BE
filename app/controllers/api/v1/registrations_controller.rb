module Api
  module V1
    class RegistrationsController < Devise::RegistrationsController
      respond_to :json

      def create
        build_resource(sign_up_params)

        resource.save
        if resource.persisted?
          render json: {
            status: { code: 200, message: 'Signed up successfully' },
            data: resource.as_json(only: [:id, :email, :username])
          }
        else
          render json: {
            status: { message: "User couldn't be created",
                    errors: resource.errors.full_messages }
          }, status: :unprocessable_entity
        end
      end

      private

      def sign_up_params
        params.require(:user).permit(:email, :password, :username)
      end
    end
  end
end
