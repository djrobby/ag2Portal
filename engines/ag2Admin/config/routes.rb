Ag2Admin::Engine.routes.draw do
  get "home/index"

  match 'config' => 'config#index', :as => :config
  match 'zipcodes/update_province_textfield/:id', :controller => 'zipcodes', :action => 'update_province_textfield'
  match 'zipcodes/:id/update_province_textfield/:id', :controller => 'zipcodes', :action => 'update_province_textfield'
  match 'companies/update_province_textfield/:id', :controller => 'companies', :action => 'update_province_textfield'
  match 'companies/:id/update_province_textfield/:id', :controller => 'companies', :action => 'update_province_textfield'

  resources :users
  resources :roles
  resources :companies
  resources :offices
  resources :provinces
  resources :towns
  resources :zipcodes

  root :to => 'home#index'
end
