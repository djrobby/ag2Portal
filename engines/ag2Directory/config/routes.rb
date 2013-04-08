Ag2Directory::Engine.routes.draw do
  get "home/index"

  resources :corp_contacts

  root :to => 'home#index'
end
