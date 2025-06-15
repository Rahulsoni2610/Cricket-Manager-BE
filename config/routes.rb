Rails.application.routes.draw do
  devise_for :users, skip: [:registrations, :sessions, :passwords]

  devise_scope :user do
    namespace :api do
      namespace :v1 do
        post 'auth/signup', to: 'registrations#create'
        post 'auth/login', to: 'sessions#create'
        delete 'auth/logout', to: 'sessions#destroy'
      end
    end
  end

  namespace :api do
    namespace :v1 do
      get 'dashboard', to: 'dashboard#index'
      resources :teams do
        get 'players', on: :member
        patch 'roles', on: :member
      end
      resources :players do
        collection do
          get 'available'
        end
      end
      resources :tournaments do
        resources :matches
      end

      resources :series do
        resources :matches
      end

      resources :matches do
        resources :innings
      end
      resources :team_tournament_players, only: [:create, :destroy]
      resource :users
    end
  end
end
