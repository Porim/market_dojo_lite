class SentryTestController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :trigger_error ]

  def trigger_error
    # This is only for testing Sentry in non-production environments
    if Rails.env.production? && params[:test_key] != ENV["SENTRY_TEST_KEY"]
      redirect_to root_path, alert: "Unauthorized"
      return
    end

    raise StandardError, "This is a test error for Sentry monitoring"
  end
end
