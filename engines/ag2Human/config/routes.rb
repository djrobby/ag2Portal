Ag2Human::Engine.routes.draw do
  get "home/index"

  # Routes to import
  match 'import' => 'import#index', :as => :import

  # Routes for jQuery POSTs
  match 'workers/update_province_textfield_from_town/:id', :controller => 'workers', :action => 'update_province_textfield_from_town'
  match 'workers/:id/update_province_textfield_from_town/:id', :controller => 'workers', :action => 'update_province_textfield_from_town'
  match 'workers/update_province_textfield_from_zipcode/:id', :controller => 'workers', :action => 'update_province_textfield_from_zipcode'
  match 'workers/:id/update_province_textfield_from_zipcode/:id', :controller => 'workers', :action => 'update_province_textfield_from_zipcode'
  match 'workers/update_code_textfield_from_name/:id', :controller => 'workers', :action => 'update_code_textfield_from_name'
  match 'workers/:id/update_code_textfield_from_name/:id', :controller => 'workers', :action => 'update_code_textfield_from_name'
  match 'workers/update_company_textfield_from_office/:id', :controller => 'workers', :action => 'update_company_textfield_from_office'
  match 'workers/:id/update_company_textfield_from_office/:id', :controller => 'workers', :action => 'update_company_textfield_from_office'
  match 'workers/update_email_textfield_from_user/:id', :controller => 'workers', :action => 'update_email_textfield_from_user'
  match 'workers/:id/update_email_textfield_from_user/:id', :controller => 'workers', :action => 'update_email_textfield_from_user'
  match 'workers/update_textfields_to_uppercase/:last/:first/:code/:fiscal', :controller => 'workers', :action => 'update_textfields_to_uppercase'
  match 'workers/:id/update_textfields_to_uppercase/:last/:first/:code/:fiscal', :controller => 'workers', :action => 'update_textfields_to_uppercase'
  match 'data_import', :controller => 'import', :action => 'data_import'

  resources :workers
  resources :collective_agreements
  resources :contract_types
  resources :degree_types
  resources :professional_groups
  resources :worker_types
  resources :departments
   
  root :to => 'home#index'
end
