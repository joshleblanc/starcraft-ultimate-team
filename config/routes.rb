Rails.application.routes.draw do
  resources :card_sets
  # Authentication
  resource :session
  resource :registration, only: %i[new create]
  resources :passwords, param: :token

  # Dashboard
  root "dashboard#show"

  # Cup Rush (Single Player)
  resource :cup_rush, only: [ :show ], controller: "cup_rush" do
    post :new_season
  end

  # Cards & Collection
  resources :cards, only: [ :index, :show ] do
    member do
      post :set_starter
      delete :remove_starter
    end
  end

  # Packs
  resources :packs, only: [ :index, :show ] do
    member do
      post :open
      get :opening
    end
  end

  # Teams
  resources :teams

  # Cup Rush Leagues
  resources :leagues do
    member do
      post :join
      post :start
    end
  end

  # Matches
  resources :matches, only: [ :index, :show ] do
    member do
      get :lineup
      post :submit_lineup
      post :simulate
      post :simulate_all
    end
  end

  # Games
  resources :games, only: [ :show ]

  # Notifications
  resources :notifications, only: [ :index ] do
    member do
      post :mark_as_read
    end
    collection do
      post :mark_all_as_read
    end
  end

  # Admin
  namespace :admin do
    resources :cards
    resources :card_sets
  end

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end
