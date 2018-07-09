Rails.application.routes.draw do
  root to: 'home#index'

  post 'scrape' => 'home#scrape'
end
