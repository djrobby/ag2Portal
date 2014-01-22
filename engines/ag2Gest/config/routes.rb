Ag2Gest::Engine.routes.draw do
  scope "(:locale)", :locale => /en|es/ do
    # Get
    get "home/index"

    # Routes to import

    # Routes to search

    # Routes for jQuery POSTs
    match 'clients/update_province_textfield_from_town/:id', :controller => 'clients', :action => 'update_province_textfield_from_town'
    match 'clients/:id/update_province_textfield_from_town/:id', :controller => 'clients', :action => 'update_province_textfield_from_town'
    match 'clients/update_province_textfield_from_zipcode/:id', :controller => 'clients', :action => 'update_province_textfield_from_zipcode'
    match 'clients/:id/update_province_textfield_from_zipcode/:id', :controller => 'clients', :action => 'update_province_textfield_from_zipcode'
    match 'clients/update_country_textfield_from_region/:id', :controller => 'clients', :action => 'update_country_textfield_from_region'
    match 'clients/:id/update_country_textfield_from_region/:id', :controller => 'clients', :action => 'update_country_textfield_from_region'
    match 'clients/update_region_textfield_from_province/:id', :controller => 'clients', :action => 'update_region_textfield_from_province'
    match 'clients/:id/update_region_textfield_from_province/:id', :controller => 'clients', :action => 'update_region_textfield_from_province'
    match 'clients/validate_fiscal_id_textfield/:id', :controller => 'clients', :action => 'validate_fiscal_id_textfield'
    match 'clients/:id/validate_fiscal_id_textfield/:id', :controller => 'clients', :action => 'validate_fiscal_id_textfield'
    match 'clients/update_code_textfield/:id', :controller => 'clients', :action => 'update_code_textfield'
    match 'clients/:id/update_code_textfield/:id', :controller => 'clients', :action => 'update_code_textfield'

    # Resources
    resources :clients
    
    # Root
    root :to => 'home#index'
  end
end
