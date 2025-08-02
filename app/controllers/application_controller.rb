class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :authenticate_user!, unless: :devise_controller?
  before_action :set_locale

  def set_locale
    I18n.locale = session[:locale] || I18n.default_locale
  end

  def switch_locale
    session[:locale] = params[:locale]
    redirect_back(fallback_location: root_path)
  end

  protected

  def require_buyer!
    redirect_to root_path, alert: "Access denied" unless current_user&.buyer?
  end

  def require_supplier!
    redirect_to root_path, alert: "Access denied" unless current_user&.supplier?
  end
end
