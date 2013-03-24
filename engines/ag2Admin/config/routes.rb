Ag2Admin::Engine.routes.draw do
  get "home/index"

  match 'config' => 'config#index', :as => :config
  
  resources :users
  resources :roles
   
  root :to => 'home#index'
end
