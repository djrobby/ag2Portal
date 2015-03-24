Ag2Admin::Engine.routes.draw do
  scope "(:locale)", :locale => /en|es/ do
    # Get
    get "home/index"

    # Route to config
    match 'config' => 'config#index', :as => :config

    # Routes for jQuery POSTs
    match 'zipcodes/update_province_textfield_from_town/:id', :controller => 'zipcodes', :action => 'update_province_textfield_from_town'
    match 'zipcodes/:id/update_province_textfield_from_town/:id', :controller => 'zipcodes', :action => 'update_province_textfield_from_town'
    #
    match 'companies/update_province_textfield_from_town/:id', :controller => 'companies', :action => 'update_province_textfield_from_town'
    match 'companies/:id/update_province_textfield_from_town/:id', :controller => 'companies', :action => 'update_province_textfield_from_town'
    match 'companies/update_province_textfield_from_zipcode/:id', :controller => 'companies', :action => 'update_province_textfield_from_zipcode'
    match 'companies/:id/update_province_textfield_from_zipcode/:id', :controller => 'companies', :action => 'update_province_textfield_from_zipcode'
    match 'companies/co_update_attachment', :controller => 'companies', :action => 'co_update_attachment'
    match 'co_update_attachment', :controller => 'companies', :action => 'co_update_attachment'
    match 'companies/:id/co_update_attachment', :controller => 'companies', :action => 'co_update_attachment'
    match 'companies/co_validate_fiscal_id_textfield/:id', :controller => 'entities', :action => 'validate_fiscal_id_textfield'
    match 'co_validate_fiscal_id_textfield/:id', :controller => 'entities', :action => 'validate_fiscal_id_textfield'
    match 'companies/:id/co_validate_fiscal_id_textfield/:id', :controller => 'entities', :action => 'validate_fiscal_id_textfield'
    #
    match 'offices/update_province_textfield_from_town/:id', :controller => 'offices', :action => 'update_province_textfield_from_town'
    match 'offices/:id/update_province_textfield_from_town/:id', :controller => 'offices', :action => 'update_province_textfield_from_town'
    match 'offices/update_province_textfield_from_zipcode/:id', :controller => 'offices', :action => 'update_province_textfield_from_zipcode'
    match 'offices/:id/update_province_textfield_from_zipcode/:id', :controller => 'offices', :action => 'update_province_textfield_from_zipcode'
    match 'offices/update_code_textfield_from_zipcode/:id', :controller => 'offices', :action => 'update_code_textfield_from_zipcode'
    match 'offices/:id/update_code_textfield_from_zipcode/:id', :controller => 'offices', :action => 'update_code_textfield_from_zipcode'
    #
    match 'entities/update_province_textfield_from_town/:id', :controller => 'entities', :action => 'update_province_textfield_from_town'
    match 'entities/:id/update_province_textfield_from_town/:id', :controller => 'entities', :action => 'update_province_textfield_from_town'
    match 'entities/update_province_textfield_from_zipcode/:id', :controller => 'entities', :action => 'update_province_textfield_from_zipcode'
    match 'entities/:id/update_province_textfield_from_zipcode/:id', :controller => 'entities', :action => 'update_province_textfield_from_zipcode'
    match 'entities/update_country_textfield_from_region/:id', :controller => 'entities', :action => 'update_country_textfield_from_region'
    match 'entities/:id/update_country_textfield_from_region/:id', :controller => 'entities', :action => 'update_country_textfield_from_region'
    match 'entities/update_region_textfield_from_province/:id', :controller => 'entities', :action => 'update_region_textfield_from_province'
    match 'entities/:id/update_region_textfield_from_province/:id', :controller => 'entities', :action => 'update_region_textfield_from_province'
    match 'entities/et_validate_fiscal_id_textfield/:id', :controller => 'entities', :action => 'validate_fiscal_id_textfield'
    match 'et_validate_fiscal_id_textfield/:id', :controller => 'entities', :action => 'validate_fiscal_id_textfield'
    match 'entities/:id/et_validate_fiscal_id_textfield/:id', :controller => 'entities', :action => 'validate_fiscal_id_textfield'
    #
    match 'areas/ar_update_worker_select_from_department/:department', :controller => 'areas', :action => 'ar_update_worker_select_from_department'
    match 'ar_update_worker_select_from_department/:department', :controller => 'areas', :action => 'ar_update_worker_select_from_department'
    match 'areas/:id/ar_update_worker_select_from_department/:department', :controller => 'areas', :action => 'ar_update_worker_select_from_department'
    #
    match 'departments/de_update_worker_select_from_company/:department', :controller => 'departments', :action => 'de_update_worker_select_from_company'
    match 'de_update_worker_select_from_company/:department', :controller => 'departments', :action => 'de_update_worker_select_from_company'
    match 'departments/:id/de_update_worker_select_from_company/:department', :controller => 'departments', :action => 'de_update_worker_select_from_company'
    match 'departments/de_update_company_select_from_organization/:department', :controller => 'departments', :action => 'de_update_company_select_from_organization'
    match 'de_update_company_select_from_organization/:department', :controller => 'departments', :action => 'de_update_company_select_from_organization'
    match 'departments/:id/de_update_company_select_from_organization/:department', :controller => 'departments', :action => 'de_update_company_select_from_organization'
    #
    match 'tax_types/:id/expire', :controller => 'tax_types', :action => 'expire'
    #
    match 'update_company_organization_from_office/:box', :controller => 'users', :action => 'update_company_organization_from_office'
    match 'update_organization_from_company/:box', :controller => 'users', :action => 'update_organization_from_company'
    #match 'render_user/:u', :controller => 'users', :action => 'render_user'
    #
    match 'guides/gu_update_site_from_app/:app', :controller => 'guides', :action => 'gu_update_site_from_app'
    match 'gu_update_site_from_app/:app', :controller => 'guides', :action => 'gu_update_site_from_app'
    match 'guides/:id/gu_update_site_from_app/:app', :controller => 'guides', :action => 'gu_update_site_from_app'
    #
    match 'ledger_accounts/la_update_project_textfield_from_organization/:org', :controller => 'ledger_accounts', :action => 'la_update_project_textfield_from_organization'
    match 'la_update_project_textfield_from_organization/:org', :controller => 'ledger_accounts', :action => 'la_update_project_textfield_from_organization'
    match 'ledger_accounts/:id/la_update_project_textfield_from_organization/:org', :controller => 'ledger_accounts', :action => 'la_update_project_textfield_from_organization'
    match 'ledger_accounts/la_update_accounting_group_from_code/:code', :controller => 'ledger_accounts', :action => 'la_update_accounting_group_from_code'
    match 'la_update_accounting_group_from_code/:code', :controller => 'ledger_accounts', :action => 'la_update_accounting_group_from_code'
    match 'ledger_accounts/:id/la_update_accounting_group_from_code/:code', :controller => 'ledger_accounts', :action => 'la_update_accounting_group_from_code'

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
    resources :tax_types
    resources :departments
    resources :areas
    resources :organizations
    resources :guides
    resources :subguides
    resources :accounting_groups
    resources :ledger_accounts
    resources :payment_methods
    
    # Root
    root :to => 'home#index'
  end
end
