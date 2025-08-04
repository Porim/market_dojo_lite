Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: "users/registrations"
  }

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Language switching
  post "switch_locale/:locale", to: "application#switch_locale", as: :switch_locale

  # Authenticated routes
  authenticated :user do
    root "dashboard#index", as: :authenticated_root
  end

  # Resources
  resources :rfqs do
    resources :quotes, only: [ :new, :create ]
    resource :auction, only: [ :show, :create ] do
      resources :bids, only: [ :create ]
    end
  end

  resources :auctions, only: [ :index ] do
    member do
      post :bid
    end
  end

  # Secure document downloads
  get "documents/:signed_id", to: "documents#show", as: :document

  # Analytics
  get "analytics", to: "analytics#index", as: :analytics

  # Reports
  resources :reports, only: [ :index ] do
    collection do
      get "spend_analysis"
      get "supplier_performance"
      get "rfq_analytics"
      get "custom_report"
    end
  end

  # API Documentation
  get "api_docs", to: "api_docs#index", as: :api_docs

  # API Token Management (for web interface)
  resource :api_tokens, only: [] do
    post :regenerate
  end

  # Sentry test endpoint (only for testing)
  get "sentry_test", to: "sentry_test#trigger_error" if Rails.env.development? || Rails.env.production?

  # API routes
  namespace :api do
    namespace :v1 do
      # Authentication
      post "auth/login", to: "auth#login"
      get "auth/profile", to: "auth#profile"
      post "auth/regenerate_token", to: "auth#regenerate_token"

      # RFQs and Quotes
      resources :rfqs do
        resources :quotes
      end

      # Analytics
      get "analytics/summary", to: "analytics#summary"
      get "analytics/rfq/:rfq_id", to: "analytics#rfq_details"
    end
  end

  # Public root
  root "dashboard#index"
end
