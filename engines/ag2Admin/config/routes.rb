Ag2Admin::Engine.routes.draw do
  get "home/index"
  
  resources :users
   
  root :to => 'home#index'
end
