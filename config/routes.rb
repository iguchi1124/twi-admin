Rails.application.routes.draw do
  root 'home#index'

  get '/auth/:provider/callback', to: 'sessions#create'
  delete '/sign_out', to: 'sessions#destroy'

  resources :friends, only: :index
  resources :followers, only: :index
  resources :unreturned_friends, only: :index
end
