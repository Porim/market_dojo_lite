# Cloud Run specific configuration
if ENV['K_SERVICE'].present?
  Rails.logger.info "Running on Cloud Run"
  
  # Increase database connection timeout for Cloud SQL
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.connection_pool.checkout_timeout = 10
  end
  
  # Skip some initializers that might cause issues during startup
  Rails.application.config.eager_load = false if ENV['SKIP_EAGER_LOAD'].present?
end