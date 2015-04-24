Ag2Human::Engine.routes.draw do
  scope "(:locale)", :locale => /en|es/ do
    # Get
    get "home/index"

    # Routes to import
    match 'import' => 'import#index', :as => :import

    # Routes to time_record
    match 'ag2_timerecord' => 'ag2_timerecord#index', :as => :ag2_timerecord
    match 'ag2_timerecord_track' => 'ag2_timerecord_track#index', :as => :ag2_timerecord_track

    # Routes for jQuery POSTs
    # Workers
    match 'workers/update_province_textfield_from_town/:id', :controller => 'workers', :action => 'update_province_textfield_from_town'
    match 'workers/:id/update_province_textfield_from_town/:id', :controller => 'workers', :action => 'update_province_textfield_from_town'
    match 'workers/update_province_textfield_from_zipcode/:id', :controller => 'workers', :action => 'update_province_textfield_from_zipcode'
    match 'workers/:id/update_province_textfield_from_zipcode/:id', :controller => 'workers', :action => 'update_province_textfield_from_zipcode'
    match 'workers/update_code_textfield_from_name/:id', :controller => 'workers', :action => 'update_code_textfield_from_name'
    match 'update_code_textfield_from_name/:id', :controller => 'workers', :action => 'update_code_textfield_from_name'
    match 'workers/:id/update_code_textfield_from_name/:id', :controller => 'workers', :action => 'update_code_textfield_from_name'
    match 'workers/update_company_textfield_from_office/:id', :controller => 'workers', :action => 'update_company_textfield_from_office'
    match 'workers/:id/update_company_textfield_from_office/:id', :controller => 'workers', :action => 'update_company_textfield_from_office'
    match 'workers/update_email_textfield_from_user/:id', :controller => 'workers', :action => 'update_email_textfield_from_user'
    match 'workers/:id/update_email_textfield_from_user/:id', :controller => 'workers', :action => 'update_email_textfield_from_user'
    match 'workers/update_textfields_to_uppercase/:last/:first/:code/:fiscal', :controller => 'workers', :action => 'update_textfields_to_uppercase'
    match 'workers/:id/update_textfields_to_uppercase/:last/:first/:code/:fiscal', :controller => 'workers', :action => 'update_textfields_to_uppercase'
    match 'update_offices_select_from_company/:com', :controller => 'workers', :action => 'update_offices_select_from_company'
    match 'workers/wk_update_attachment', :controller => 'workers', :action => 'wk_update_attachment'
    match 'wk_update_attachment', :controller => 'workers', :action => 'wk_update_attachment'
    match 'workers/:id/wk_update_attachment', :controller => 'workers', :action => 'wk_update_attachment'
    match 'workers/wk_validate_fiscal_id_textfield/:id', :controller => 'workers', :action => 'validate_fiscal_id_textfield'
    match 'wk_validate_fiscal_id_textfield/:id', :controller => 'workers', :action => 'validate_fiscal_id_textfield'
    match 'workers/:id/wk_validate_fiscal_id_textfield/:id', :controller => 'workers', :action => 'validate_fiscal_id_textfield'
    #
    # Time record
    match 'worker_report', :controller => 'ag2_timerecord_track', :action => 'worker_report'
    match 'office_report', :controller => 'ag2_timerecord_track', :action => 'office_report'
    match 'update_workers_select_from_office/:id', :controller => 'ag2_timerecord_track', :action => 'update_workers_select_from_office'
    #
    # Worker items
    match 'worker_items/update_company_textfield_from_office/:id', :controller => 'worker_items', :action => 'update_company_textfield_from_office'
    match 'update_company_textfield_from_office/:id', :controller => 'worker_items', :action => 'update_company_textfield_from_office'
    match 'worker_items/:id/update_company_textfield_from_office/:id', :controller => 'worker_items', :action => 'update_company_textfield_from_office'
    #
    # Worker salaries
    match 'worker_salaries/ws_update_amounts/:gs/:vs/:ss/:dp/:ot', :controller => 'worker_salaries', :action => 'ws_update_amounts'
    match 'ws_update_amounts/:gs/:vs/:ss/:dp/:ot', :controller => 'worker_salaries', :action => 'wsi_update_amount'
    match 'worker_salaries/:id/ws_update_amounts/:gs/:vs/:ss/:dp/:ot', :controller => 'worker_salaries', :action => 'ws_update_amounts'
    #
    # Worker salary items
    match 'worker_salary_items/wsi_update_amount/:amount', :controller => 'worker_salary_items', :action => 'wsi_update_amount'
    match 'wsi_update_amount/:amount', :controller => 'worker_salary_items', :action => 'wsi_update_amount'
    match 'worker_salary_items/:id/wsi_update_amount/:amount', :controller => 'worker_salary_items', :action => 'wsi_update_amount'
    #
    # Data import
    match 'data_import', :controller => 'import', :action => 'data_import'
    #
    # Departments
    match 'departments/de_update_worker_select_from_company/:department', :controller => 'departments', :action => 'de_update_worker_select_from_company'
    match 'de_update_worker_select_from_company/:department', :controller => 'departments', :action => 'de_update_worker_select_from_company'
    match 'departments/:id/de_update_worker_select_from_company/:department', :controller => 'departments', :action => 'de_update_worker_select_from_company'
    match 'departments/de_update_company_select_from_organization/:department', :controller => 'departments', :action => 'de_update_company_select_from_organization'
    match 'de_update_company_select_from_organization/:department', :controller => 'departments', :action => 'de_update_company_select_from_organization'
    match 'departments/:id/de_update_company_select_from_organization/:department', :controller => 'departments', :action => 'de_update_company_select_from_organization'

    # Resources
    resources :workers
    resources :collective_agreements
    resources :contract_types
    resources :degree_types
    resources :professional_groups
    resources :worker_types
    resources :departments
    resources :timerecord_codes
    resources :timerecord_types
    resources :time_records
    resources :insurances
    resources :salary_concepts
    resources :worker_items
    resources :worker_salaries
    resources :worker_salary_items
    
    # Root
    root :to => 'home#index'
  end

  # Routes to search (advanced) - ONLY if search view/method is used! -
  # match '/workers/search', :controller => 'workers', :action => 'search'
  # match '/time_records/search', :controller => 'time_records', :action => 'search'
end
