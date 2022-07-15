Rails.application.routes.draw do
  devise_for :users
  root "static_pages#root"
  resource :dashboard, only: [:show]
  resource :pricing, only: [:show]
  resources :webhooks, only: [:create]
end
