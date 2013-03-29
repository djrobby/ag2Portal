Ag2Admin::Engine.routes.draw do
  get "home/index"

  match 'config' => 'config#index', :as => :config

  match 'zipcodes/update_province_textfield_from_town/:id', :controller => 'zipcodes', :action => 'update_province_textfield_from_town'
  match 'zipcodes/:id/update_province_textfield_from_town/:id', :controller => 'zipcodes', :action => 'update_province_textfield_from_town'
  match 'companies/update_province_textfield_from_town/:id', :controller => 'companies', :action => 'update_province_textfield_from_town'
  match 'companies/:id/update_province_textfield_from_town/:id', :controller => 'companies', :action => 'update_province_textfield_from_town'
  match 'companies/update_province_textfield_from_zipcode/:id', :controller => 'companies', :action => 'update_province_textfield_from_zipcode'
  match 'companies/:id/update_province_textfield_from_zipcode/:id', :controller => 'companies', :action => 'update_province_textfield_from_zipcode'

  resources :users
  resources :roles
  resources :companies
  resources :offices
  resources :provinces
  resources :towns
  resources :zipcodes
  resources :street_types

  root :to => 'home#index'
end
