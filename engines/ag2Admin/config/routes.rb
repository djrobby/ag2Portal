Ag2Admin::Engine.routes.draw do
  get "home/index"

  resources :users
  resources :roles
   
  root :to => 'home#index'
end
