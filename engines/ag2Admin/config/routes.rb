Ag2Admin::Engine.routes.draw do
  scope "(:locale)", :locale => /en|es/ do
    # Get
    get "home/index"

    # Route to config
    match 'config' => 'config#index', :as => :config

    # Routes for jQuery POSTs
    #
    # ZIP codes 
    match 'zipcodes/update_province_textfield_from_town/:id', :controller => 'zipcodes', :action => 'update_province_textfield_from_town'
    match 'zipcodes/:id/update_province_textfield_from_town/:id', :controller => 'zipcodes', :action => 'update_province_textfield_from_town'
    #
    # Companies 
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
    match 'companies/co_update_total_and_price/:total/:price', :controller => 'companies', :action => 'co_update_total_and_price'
    match 'co_update_total_and_price/:total/:price', :controller => 'companies', :action => 'co_update_total_and_price'
    match 'companies/:id/co_update_total_and_price/:total/:price', :controller => 'companies', :action => 'co_update_total_and_price'
    match 'companies/co_update_from_organization/:company', :controller => 'companies', :action => 'co_update_from_organization'
    match 'co_update_from_organization/:company', :controller => 'companies', :action => 'co_update_from_organization'
    match 'companies/:id/co_update_from_organization/:company', :controller => 'companies', :action => 'co_update_from_organization'
    #
    # Offices 
    match 'offices/update_province_textfield_from_town/:id', :controller => 'offices', :action => 'update_province_textfield_from_town'
    match 'offices/:id/update_province_textfield_from_town/:id', :controller => 'offices', :action => 'update_province_textfield_from_town'
    match 'offices/update_province_textfield_from_zipcode/:id', :controller => 'offices', :action => 'update_province_textfield_from_zipcode'
    match 'offices/:id/update_province_textfield_from_zipcode/:id', :controller => 'offices', :action => 'update_province_textfield_from_zipcode'
    match 'offices/update_code_textfield_from_zipcode/:id', :controller => 'offices', :action => 'update_code_textfield_from_zipcode'
    match 'offices/:id/update_code_textfield_from_zipcode/:id', :controller => 'offices', :action => 'update_code_textfield_from_zipcode'
    match 'offices/co_update_total_and_price/:total/:price', :controller => 'companies', :action => 'co_update_total_and_price'
    match 'co_update_total_and_price/:total/:price', :controller => 'companies', :action => 'co_update_total_and_price'
    match 'offices/:id/co_update_total_and_price/:total/:price', :controller => 'companies', :action => 'co_update_total_and_price'
    #
    # Entities 
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
    # Areas 
    match 'areas/ar_update_worker_select_from_department/:department', :controller => 'areas', :action => 'ar_update_worker_select_from_department'
    match 'ar_update_worker_select_from_department/:department', :controller => 'areas', :action => 'ar_update_worker_select_from_department'
    match 'areas/:id/ar_update_worker_select_from_department/:department', :controller => 'areas', :action => 'ar_update_worker_select_from_department'
    #
    # Departments 
    match 'departments/de_update_worker_select_from_company/:department', :controller => 'departments', :action => 'de_update_worker_select_from_company'
    match 'de_update_worker_select_from_company/:department', :controller => 'departments', :action => 'de_update_worker_select_from_company'
    match 'departments/:id/de_update_worker_select_from_company/:department', :controller => 'departments', :action => 'de_update_worker_select_from_company'
    match 'departments/de_update_company_select_from_organization/:department', :controller => 'departments', :action => 'de_update_company_select_from_organization'
    match 'de_update_company_select_from_organization/:department', :controller => 'departments', :action => 'de_update_company_select_from_organization'
    match 'departments/:id/de_update_company_select_from_organization/:department', :controller => 'departments', :action => 'de_update_company_select_from_organization'
    #
    # Tax types 
    match 'tax_types/:id/expire', :controller => 'tax_types', :action => 'expire'
    match 'tax_types/tt_update_tax/:total', :controller => 'tax_types', :action => 'tt_update_tax'
    match 'tt_update_tax/:total', :controller => 'tax_types', :action => 'tt_update_tax'
    match 'tax_types/:id/tt_update_tax/:total', :controller => 'tax_types', :action => 'tt_update_tax'
    #
    # Users 
    match 'update_company_organization_from_office/:box', :controller => 'users', :action => 'update_company_organization_from_office'
    match 'update_organization_from_company/:box', :controller => 'users', :action => 'update_organization_from_company'
    #match 'render_user/:u', :controller => 'users', :action => 'render_user'
    #
    # Guides 
    match 'guides/gu_update_site_from_app/:app', :controller => 'guides', :action => 'gu_update_site_from_app'
    match 'gu_update_site_from_app/:app', :controller => 'guides', :action => 'gu_update_site_from_app'
    match 'guides/:id/gu_update_site_from_app/:app', :controller => 'guides', :action => 'gu_update_site_from_app'
    #
    # Ledger accounts 
    match 'ledger_accounts/la_update_project_textfield_from_organization/:org', :controller => 'ledger_accounts', :action => 'la_update_project_textfield_from_organization'
    match 'la_update_project_textfield_from_organization/:org', :controller => 'ledger_accounts', :action => 'la_update_project_textfield_from_organization'
    match 'ledger_accounts/:id/la_update_project_textfield_from_organization/:org', :controller => 'ledger_accounts', :action => 'la_update_project_textfield_from_organization'
    match 'ledger_accounts/la_update_accounting_group_from_code/:code', :controller => 'ledger_accounts', :action => 'la_update_accounting_group_from_code'
    match 'la_update_accounting_group_from_code/:code', :controller => 'ledger_accounts', :action => 'la_update_accounting_group_from_code'
    match 'ledger_accounts/:id/la_update_accounting_group_from_code/:code', :controller => 'ledger_accounts', :action => 'la_update_accounting_group_from_code'
    #
    # Payment methods
    match 'payment_methods/pm_format_numbers/:num', :controller => 'payment_methods', :action => 'pm_format_numbers'
    match 'pm_format_numbers/:num', :controller => 'payment_methods', :action => 'pm_format_numbers'
    match 'payment_methods/:id/pm_format_numbers/:num', :controller => 'payment_methods', :action => 'pm_format_numbers'
    #
    # Bank offices 
    match 'bank_offices/bo_update_province_textfield_from_town/:id', :controller => 'bank_offices', :action => 'bo_update_province_textfield_from_town'
    match 'bank_offices/:id/bo_update_province_textfield_from_town/:id', :controller => 'bank_offices', :action => 'bo_update_province_textfield_from_town'
    match 'bank_offices/bo_update_province_textfield_from_zipcode/:id', :controller => 'bank_offices', :action => 'bo_update_province_textfield_from_zipcode'
    match 'bank_offices/:id/bo_update_province_textfield_from_zipcode/:id', :controller => 'bank_offices', :action => 'bo_update_province_textfield_from_zipcode'
    match 'bank_offices/bo_update_country_textfield_from_region/:id', :controller => 'bank_offices', :action => 'bo_update_country_textfield_from_region'
    match 'bank_offices/:id/bo_update_country_textfield_from_region/:id', :controller => 'bank_offices', :action => 'bo_update_country_textfield_from_region'
    match 'bank_offices/bo_update_region_textfield_from_province/:id', :controller => 'bank_offices', :action => 'bo_update_region_textfield_from_province'
    match 'bank_offices/:id/bo_update_region_textfield_from_province/:id', :controller => 'bank_offices', :action => 'bo_update_region_textfield_from_province'

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
    resources :notifications
    resources :banks
    resources :bank_offices
    resources :bank_account_classes
    
    # Root
    root :to => 'home#index'
  end
end
