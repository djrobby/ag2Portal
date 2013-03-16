Ag2Human::Engine.routes.draw do
  get "home/index"
   
  root :to => 'home#index'
end
