Rails.application.routes.draw do
  root 'home#index'

  get '/auth/twitter', as: 'sign_in'
  get '/auth/:provider/callback', to: 'sessions#create'
  delete '/sign_out', to: 'sessions#destroy', as: 'sign_out'

  resources :friends, only: %i(index create destroy)
  resources :followers, only: :index
  resources :unreturned_friends, only: :index
end
