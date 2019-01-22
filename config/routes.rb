Rails.application.routes.draw do
  resources :sessions

  get 'home', to: 'home#index', as: :home
  get 'home/search', to: 'home#search', as: :search

  get 'login', to: 'sessions#new', as: :login
  get 'logout', to: 'sessions#destroy', as: :logout

  root 'home#index'
end
