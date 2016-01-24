Ag2Gest::Engine.routes.draw do
  scope "(:locale)", :locale => /en|es/ do
    # Get
    get "home/index"

    # Routes to import

    # Routes to search

    # Routes for jQuery POSTs
    #
    # Clients
    match 'clients/update_province_textfield_from_town/:id', :controller => 'clients', :action => 'update_province_textfield_from_town'
    match 'clients/:id/update_province_textfield_from_town/:id', :controller => 'clients', :action => 'update_province_textfield_from_town'
    match 'clients/update_province_textfield_from_zipcode/:id', :controller => 'clients', :action => 'update_province_textfield_from_zipcode'
    match 'clients/:id/update_province_textfield_from_zipcode/:id', :controller => 'clients', :action => 'update_province_textfield_from_zipcode'
    match 'clients/update_country_textfield_from_region/:id', :controller => 'clients', :action => 'update_country_textfield_from_region'
    match 'clients/:id/update_country_textfield_from_region/:id', :controller => 'clients', :action => 'update_country_textfield_from_region'
    match 'clients/update_region_textfield_from_province/:id', :controller => 'clients', :action => 'update_region_textfield_from_province'
    match 'clients/:id/update_region_textfield_from_province/:id', :controller => 'clients', :action => 'update_region_textfield_from_province'
    match 'clients/validate_fiscal_id_textfield/:id', :controller => 'clients', :action => 'validate_fiscal_id_textfield'
    match 'validate_fiscal_id_textfield/:id', :controller => 'clients', :action => 'validate_fiscal_id_textfield'
    match 'clients/:id/validate_fiscal_id_textfield/:id', :controller => 'clients', :action => 'validate_fiscal_id_textfield'
    match 'clients/cl_generate_code/:id', :controller => 'clients', :action => 'cl_generate_code'
    match 'cl_generate_code/:id', :controller => 'clients', :action => 'cl_generate_code'
    match 'clients/:id/cl_generate_code/:id', :controller => 'clients', :action => 'cl_generate_code'
    match 'clients/et_validate_fiscal_id_textfield/:id', :controller => 'clients', :action => 'et_validate_fiscal_id_textfield'
    match 'et_validate_fiscal_id_textfield/:id', :controller => 'clients', :action => 'et_validate_fiscal_id_textfield'
    match 'clients/:id/et_validate_fiscal_id_textfield/:id', :controller => 'clients', :action => 'et_validate_fiscal_id_textfield'
    match 'clients/cl_update_textfields_from_organization/:org', :controller => 'clients', :action => 'cl_update_textfields_from_organization'
    match 'cl_update_textfields_from_organization/:org', :controller => 'clients', :action => 'cl_update_textfields_from_organization'
    match 'clients/:id/cl_update_textfields_from_organization/:org', :controller => 'clients', :action => 'cl_update_textfields_from_organization'
    #
    # Payment methods
    match 'payment_methods/pm_format_numbers/:num', :controller => 'payment_methods', :action => 'pm_format_numbers'
    match 'pm_format_numbers/:num', :controller => 'payment_methods', :action => 'pm_format_numbers'
    match 'payment_methods/:id/pm_format_numbers/:num', :controller => 'payment_methods', :action => 'pm_format_numbers'

    # Resources
    resources :clients
    resources :sale_offers
    resources :payment_methods

    # Root
    root :to => 'home#index'
  end
end
