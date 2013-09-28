Ag2Purchase::Engine.routes.draw do
  scope "(:locale)", :locale => /en|es/ do
    # Get
    get "home/index"
    
    # Routes for jQuery POSTs
    match 'suppliers/update_province_textfield_from_town/:id', :controller => 'suppliers', :action => 'update_province_textfield_from_town'
    match 'suppliers/:id/update_province_textfield_from_town/:id', :controller => 'suppliers', :action => 'update_province_textfield_from_town'
    match 'suppliers/update_province_textfield_from_zipcode/:id', :controller => 'suppliers', :action => 'update_province_textfield_from_zipcode'
    match 'suppliers/:id/update_province_textfield_from_zipcode/:id', :controller => 'suppliers', :action => 'update_province_textfield_from_zipcode'
    match 'suppliers/update_country_textfield_from_region/:id', :controller => 'suppliers', :action => 'update_country_textfield_from_region'
    match 'suppliers/:id/update_country_textfield_from_region/:id', :controller => 'suppliers', :action => 'update_country_textfield_from_region'
    match 'suppliers/update_region_textfield_from_province/:id', :controller => 'suppliers', :action => 'update_region_textfield_from_province'
    match 'suppliers/:id/update_region_textfield_from_province/:id', :controller => 'suppliers', :action => 'update_region_textfield_from_province'
    match 'suppliers/validate_fiscal_id_textfield/:id', :controller => 'suppliers', :action => 'validate_fiscal_id_textfield'
    match 'suppliers/:id/validate_fiscal_id_textfield/:id', :controller => 'suppliers', :action => 'validate_fiscal_id_textfield'

    # Resources
    resources :suppliers
    resources :activities
    resources :payment_methods

    # Root
    root :to => 'home#index'
  end
end
