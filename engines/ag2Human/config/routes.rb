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
    match 'worker_report', :controller => 'ag2_timerecord_track', :action => 'worker_report'
    match 'office_report', :controller => 'ag2_timerecord_track', :action => 'office_report'
    match 'update_workers_select_from_office/:id', :controller => 'ag2_timerecord_track', :action => 'update_workers_select_from_office'
    match 'update_offices_select_from_company/:id', :controller => 'workers', :action => 'update_offices_select_from_company'

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
    
    # Root
    root :to => 'home#index'
  end

  # Routes to search (advanced) - ONLY if search view/method is used! -
  # match '/workers/search', :controller => 'workers', :action => 'search'
  # match '/time_records/search', :controller => 'time_records', :action => 'search'
end
