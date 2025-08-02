class ApiDocsController < ApplicationController
  before_action :authenticate_user!

  def index
    # This will render the API documentation view
  end
end
