Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Authenticated routes
  authenticated :user do
    root 'dashboard#index', as: :authenticated_root
  end

  # Resources
  resources :rfqs do
    resources :quotes, only: [:new, :create]
    resource :auction, only: [:show, :create] do
      resources :bids, only: [:create]
    end
  end

  resources :auctions, only: [:index] do
    member do
      post :bid
    end
  end

  # Public root
  root "dashboard#index"
end