Rails.application.routes.draw do
  root to: 'home#index'

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  post 'scrape' => 'home#scrape'
end
