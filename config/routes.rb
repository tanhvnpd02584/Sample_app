Rails.application.routes.draw do
<<<<<<< HEAD
  root "static_pages#index"
  get "/help", to: "static_pages#help"
  resources :users, only: %i(new show create)
end
=======
  get "static_pages/home"
  get "static_pages/help"
  get "static_pages/login"
end


>>>>>>> 0cc3c62a102ae874de932e0b70c15767e415dd66
