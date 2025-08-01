class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :authenticate_user!, unless: :devise_controller?

  protected

  def require_buyer!
    redirect_to root_path, alert: "Access denied" unless current_user&.buyer?
  end

  def require_supplier!
    redirect_to root_path, alert: "Access denied" unless current_user&.supplier?
  end
end
