Rails.application.routes.draw do
  devise_for :users

  get 'search', to: 'search#index', as: :search

  resources :customers
  resources :deliveries
  resources :bottles

  get 'dashboard' => 'dashboard#index'
  root to: 'dashboard#index'
end
