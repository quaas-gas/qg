Rails.application.routes.draw do
  devise_for :users

  get 'search', to: 'search#index', as: :search

  resources :customers, shallow: true do
    resources :prices
  end
  resources :deliveries
  resources :invoices
  resources :products
  resources :sellers, except: :show

  get 'dashboard' => 'dashboard#index'
  root to: 'dashboard#show'
end
