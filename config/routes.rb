Rails.application.routes.draw do
  devise_for :users
  root "static_pages#root"
  resource :dashboard, only: [:show]
  resource :billing
  resources :webhooks, only: [:create]
  resource :pricing
end
