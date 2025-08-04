class ApiTokensController < ApplicationController
  before_action :authenticate_user!

  def regenerate
    current_user.regenerate_api_token!

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "api_token_section",
          partial: "api_docs/token_section",
          locals: { user: current_user }
        )
      end
      format.html do
        redirect_to api_docs_path, notice: "API token regenerated successfully"
      end
      format.json do
        render json: {
          message: "API token regenerated successfully",
          api_token: current_user.api_token
        }
      end
    end
  end
end
