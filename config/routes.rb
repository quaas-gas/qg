Rails.application.routes.draw do
  devise_for :users

  get 'search', to: 'search#index', as: :search

  resources :customers
  resources :deliveries

  get 'dashboard' => 'dashboard#index'
  root to: 'dashboard#index'
end
