Sentry.init do |config|
  config.dsn = ENV['SENTRY_DSN']
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]

  # Set traces_sample_rate to 1.0 to capture 100%
  # of transactions for tracing.
  # We recommend adjusting this value in production
  config.traces_sample_rate = 0.5
  # or
  config.traces_sampler = lambda do |context|
    # Use a lower sample rate for health check endpoints
    if context[:transaction_context][:name] == 'ApplicationController#health'
      0.0
    else
      0.5
    end
  end

  # Set profiles_sample_rate to profile 100%
  # of sampled transactions.
  # We recommend adjusting this value in production.
  config.profiles_sample_rate = 0.5

  # Filter sensitive data
  config.before_send = lambda do |event, hint|
    # Filter out sensitive parameters
    if event.request
      event.request.data = filter_sensitive_data(event.request.data) if event.request.data
    end
    event
  end

  # Only enable Sentry in production and staging
  config.enabled_environments = %w[production staging]
  
  # Performance monitoring
  config.enable_tracing = true
  
  # Release tracking
  config.release = ENV['RENDER_GIT_COMMIT'] || ENV['GITHUB_SHA'] || 'unknown'
  
  # Don't report certain exceptions
  config.excluded_exceptions += [
    'ActionController::RoutingError',
    'ActiveRecord::RecordNotFound',
    'ActionController::UnknownFormat'
  ]
end

def filter_sensitive_data(data)
  return data unless data.is_a?(Hash)
  
  sensitive_keys = %w[password password_confirmation api_token secret token]
  
  data.each_with_object({}) do |(key, value), filtered|
    if sensitive_keys.include?(key.to_s.downcase)
      filtered[key] = '[FILTERED]'
    elsif value.is_a?(Hash)
      filtered[key] = filter_sensitive_data(value)
    else
      filtered[key] = value
    end
  end
end