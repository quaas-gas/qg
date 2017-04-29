Rails.application.routes.draw do
  devise_for :users

  get 'search', to: 'search#index', as: :search

  resources :customers do
    get :price
  end
  resources :deliveries
  resources :invoices
  resources :products, except: :index do
    get '(/:group)' => :index, on: :collection, as: ''
  end
  resources :sellers, except: :show
  resources :reports do
    get :free, on: :collection
  end
  resources :statistics do
    get :preview, on: :collection
    get :overview, on: :collection
  end

  get 'dashboard' => 'dashboard#index'
  root to: 'dashboard#show'
end
