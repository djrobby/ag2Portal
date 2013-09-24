Ag2Admin::Engine.routes.draw do
  scope "(:locale)", :locale => /en|es/ do
    # Get
    get "home/index"

    # Route to config
    match 'config' => 'config#index', :as => :config

    # Routes for jQuery POSTs
    match 'zipcodes/update_province_textfield_from_town/:id', :controller => 'zipcodes', :action => 'update_province_textfield_from_town'
    match 'zipcodes/:id/update_province_textfield_from_town/:id', :controller => 'zipcodes', :action => 'update_province_textfield_from_town'
    match 'companies/update_province_textfield_from_town/:id', :controller => 'companies', :action => 'update_province_textfield_from_town'
    match 'companies/:id/update_province_textfield_from_town/:id', :controller => 'companies', :action => 'update_province_textfield_from_town'
    match 'companies/update_province_textfield_from_zipcode/:id', :controller => 'companies', :action => 'update_province_textfield_from_zipcode'
    match 'companies/:id/update_province_textfield_from_zipcode/:id', :controller => 'companies', :action => 'update_province_textfield_from_zipcode'
    match 'offices/update_province_textfield_from_town/:id', :controller => 'offices', :action => 'update_province_textfield_from_town'
    match 'offices/:id/update_province_textfield_from_town/:id', :controller => 'offices', :action => 'update_province_textfield_from_town'
    match 'offices/update_province_textfield_from_zipcode/:id', :controller => 'offices', :action => 'update_province_textfield_from_zipcode'
    match 'offices/:id/update_province_textfield_from_zipcode/:id', :controller => 'offices', :action => 'update_province_textfield_from_zipcode'
    match 'offices/update_code_textfield_from_zipcode/:id', :controller => 'offices', :action => 'update_code_textfield_from_zipcode'
    match 'offices/:id/update_code_textfield_from_zipcode/:id', :controller => 'offices', :action => 'update_code_textfield_from_zipcode'

    # Resources
    resources :users
    resources :roles
    resources :companies
    resources :offices
    resources :provinces
    resources :towns
    resources :zipcodes
    resources :street_types
    resources :sites
    resources :apps
    resources :countries
    resources :regions
    resources :data_import_configs
    resources :entity_types
    resources :entities
    
    # Root
    root :to => 'home#index'
  end
end
