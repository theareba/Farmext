Ukulima::Application.routes.draw do
  mount KannelRails::Engine => '/sms'
  root to: 'admin/dashboard#index'

  get 'signup', to: 'admin#new', as: 'signup'
  get 'login', to: 'sessions#new', as: 'login'
  get 'logout', to: 'sessions#destroy', as: 'logout'

  resources :sessions
  resources :users
  resources :products
  resources :farmers

  namespace :admin do
    get '', to: 'dashboard#index', as: '/'
    get 'farmers', to: 'users#farmers'
    get 'buyers', to: 'users#buyers'
    match '/message', to: 'dashboard#message', via: [:get, :post]
    resources :users
    resources :admins
  end
end
