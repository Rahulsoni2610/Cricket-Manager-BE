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
      resources :teams
      resources :players, except: [:new, :edit]
      resources :tournaments do
        resources :matches
      end

      resources :series do
        resources :matches
      end

      resources :matches do
        resources :innings
      end
    end
  end
end
