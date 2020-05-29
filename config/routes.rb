Rails.application.routes.draw do
  get "sessions/new"
  get "/home", to: "static_pages#home", as: "home"
  get "/help", to: "static_pages#help", as: "help"
  get "/login", to: "sessions#new"
  post "/login", to: "sessions#create"
  delete "/logout", to: "sessions#destroy"
  resources :users
  resources :account_activations, only: :edit
  resources :password_resets, except: %i(new create edit update)
  resources :microposts, only: %i(create destroy)
end
