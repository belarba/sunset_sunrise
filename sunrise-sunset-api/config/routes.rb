# config/routes.rb
Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :sunrise_sunset, only: [:index] do
        collection do
          get :locations
        end
      end
    end
  end

  # Root endpoint
  root to: proc { [200, {}, ['Sunrise Sunset API - Ready']] }
end
