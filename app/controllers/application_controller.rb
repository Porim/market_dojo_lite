class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :authenticate_user!, unless: :devise_controller?
  before_action :set_locale
  before_action :set_sentry_context

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

  private

  def set_sentry_context
    return unless current_user

    Sentry.set_user(
      id: current_user.id,
      email: current_user.email,
      username: current_user.name,
      role: current_user.role,
      company: current_user.company_name
    )

    Sentry.set_context("browser", {
      user_agent: request.user_agent,
      ip_address: request.ip
    })
  end
end
