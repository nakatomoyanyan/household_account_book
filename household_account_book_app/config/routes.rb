Rails.application.routes.draw do
  get "static_pages/home", to: "static_pages#home"
  resources :users
  get "users/new", to: "users#new"
end
