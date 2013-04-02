Ag2Human::Engine.routes.draw do
  get "home/index"

  # Routes for jQuery POSTs
  match 'workers/update_province_textfield_from_town/:id', :controller => 'workers', :action => 'update_province_textfield_from_town'
  match 'workers/:id/update_province_textfield_from_town/:id', :controller => 'workers', :action => 'update_province_textfield_from_town'
  match 'workers/update_province_textfield_from_zipcode/:id', :controller => 'workers', :action => 'update_province_textfield_from_zipcode'
  match 'workers/:id/update_province_textfield_from_zipcode/:id', :controller => 'workers', :action => 'update_province_textfield_from_zipcode'
  match 'workers/update_code_textfield_from_name/:id', :controller => 'workers', :action => 'update_code_textfield_from_name'
  match 'workers/:id/update_code_textfield_from_name/:id', :controller => 'workers', :action => 'update_code_textfield_from_name'

  resources :workers
   
  root :to => 'home#index'
end
