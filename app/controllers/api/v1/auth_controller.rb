module Api
  module V1
    class AuthController < BaseController
      skip_before_action :authenticate_api_user!, only: [ :login ]

      def login
        user = User.find_by(email: params[:email])

        if user&.valid_password?(params[:password])
          render json: {
            user: user_json(user),
            api_token: user.api_token
          }
        else
          render json: { error: "Invalid email or password" }, status: :unauthorized
        end
      end

      def profile
        render json: { user: user_json(current_api_user) }
      end

      def regenerate_token
        current_api_user.regenerate_api_token!
        render json: {
          message: "API token regenerated successfully",
          api_token: current_api_user.api_token
        }
      end

      private

      def user_json(user)
        {
          id: user.id,
          email: user.email,
          name: user.name,
          role: user.role,
          company_name: user.company_name,
          phone: user.phone,
          created_at: user.created_at
        }
      end
    end
  end
end
