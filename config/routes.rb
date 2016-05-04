Rails.application.routes.draw do
  devise_for :users

  resources :customers

  get 'dashboard' => 'dashboard#index'
  root to: 'dashboard#index'
end
