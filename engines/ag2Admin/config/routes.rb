Ag2Admin::Engine.routes.draw do
  get "home/index"

  match 'config' => 'config#index', :as => :config
  
  resources :users
  resources :roles
  resources :companies
  resources :offices
  resources :provinces
  resources :towns
   
  root :to => 'home#index'
end
