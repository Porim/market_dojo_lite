module Api
  module V1
    class BaseController < ActionController::API
      include ActionController::HttpAuthentication::Token::ControllerMethods

      before_action :authenticate_api_user!
      before_action :set_default_format

      rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
      rescue_from ActiveRecord::RecordInvalid, with: :record_invalid

      private

      def authenticate_api_user!
        authenticate_or_request_with_http_token do |token|
          @current_api_user = User.find_by(api_token: token)
        end
      end

      def current_api_user
        @current_api_user
      end

      def record_not_found(exception)
        render json: { error: exception.message }, status: :not_found
      end

      def record_invalid(exception)
        render json: { errors: exception.record.errors.full_messages }, status: :unprocessable_entity
      end

      def set_default_format
        request.format = :json
      end

      def pagination_dict(collection)
        {
          current_page: collection.current_page,
          next_page: collection.next_page,
          prev_page: collection.prev_page,
          total_pages: collection.total_pages,
          total_count: collection.total_count
        }
      end
    end
  end
end
