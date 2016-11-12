Ag2Gest::Engine.routes.draw do
  scope "(:locale)", :locale => /en|es/ do
    # Get
    get "home/index"

    # Routes to import

    # Routes to search

    # Routes to Control&Tracking
    match 'ag2_gest_track' => 'ag2_gest_track#index', :as => :ag2_gest_track
    #
    # Control&Tracking
    match 'subscriber_report', :controller => 'subscribers', :action => 'subscriber_report'
    match 'subscriber_tec_report', :controller => 'subscribers', :action => 'subscriber_tec_report'
    match 'subscriber_eco_report', :controller => 'subscribers', :action => 'subscriber_eco_report'

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
    #
    # Home submenus (management)
    match "tariff_management", controller: "home", action: 'tariff_management'
    match "meter_management", controller: "home", action: 'meter_management'
    match "reading_management", controller: "home", action: 'reading_management'
    match "contracting_management", controller: "home", action: 'contracting_management'
    match "service_point_management", controller: "home", action: 'service_point_management'
    match "regulation_management", controller: "home", action: 'regulation_management'
    match "bill_management", controller: "home", action: 'bill_management'
    #
    # Contracting request
    match 'contracting_requests/update_bank_offices_from_bank/:id', :controller => 'contracting_requests', :action => 'update_bank_offices_from_bank'
    match 'contracting_requests/update_subscriber_from_service_point/:id', :controller => 'contracting_requests', :action => 'update_subscriber_from_service_point'
    match 'contracting_requests/update_province_textfield_from_town/:id', :controller => 'contracting_requests', :action => 'update_province_textfield_from_town'
    match 'contracting_requests/:id/update_province_textfield_from_town/:id', :controller => 'contracting_requests', :action => 'update_province_textfield_from_town'
    match 'contracting_requests/update_province_textfield_from_zipcode/:id', :controller => 'contracting_requests', :action => 'update_province_textfield_from_zipcode'
    match 'contracting_requests/:id/update_province_textfield_from_zipcode/:id', :controller => 'contracting_requests', :action => 'update_province_textfield_from_zipcode'
    match 'contracting_requests/update_province_textfield_from_street_directory/:id', :controller => 'contracting_requests', :action => 'update_province_textfield_from_street_directory'
    match 'contracting_requests/:id/update_province_textfield_from_street_directory/:id', :controller => 'contracting_requests', :action => 'update_province_textfield_from_street_directory'
    match 'contracting_requests/update_country_textfield_from_region/:id', :controller => 'contracting_requests', :action => 'update_country_textfield_from_region'
    match 'contracting_requests/:id/update_country_textfield_from_region/:id', :controller => 'contracting_requests', :action => 'update_country_textfield_from_region'
    match 'contracting_requests/update_region_textfield_from_province/:id', :controller => 'contracting_requests', :action => 'update_region_textfield_from_province'
    match 'contracting_requests/:id/update_region_textfield_from_province/:id', :controller => 'contracting_requests', :action => 'update_region_textfield_from_province'
    match 'contracting_requests/validate_fiscal_id_textfield/:id', :controller => 'contracting_requests', :action => 'validate_fiscal_id_textfield'
    match 'validate_fiscal_id_textfield/:id', :controller => 'contracting_requests', :action => 'validate_fiscal_id_textfield'
    match 'contracting_requests/:id/validate_fiscal_id_textfield/:id', :controller => 'contracting_requests', :action => 'validate_fiscal_id_textfield'
    match 'contracting_requests/validate_r_fiscal_id_textfield/:id', :controller => 'contracting_requests', :action => 'validate_r_fiscal_id_textfield'
    match 'validate_r_fiscal_id_textfield/:id', :controller => 'contracting_requests', :action => 'validate_r_fiscal_id_textfield'
    match 'contracting_requests/:id/validate_r_fiscal_id_textfield/:id', :controller => 'contracting_requests', :action => 'validate_r_fiscal_id_textfield'
    match 'contracting_requests/cr_generate_no/:id', :controller => 'contracting_requests', :action => 'cr_generate_no'
    match 'cr_generate_no/:id', :controller => 'contracting_requests', :action => 'cr_generate_no'
    match 'contracting_requests/:id/cr_generate_no/:id', :controller => 'contracting_requests', :action => 'cr_generate_no'
    match 'contracting_requests/et_validate_fiscal_id_textfield/:id', :controller => 'contracting_requests', :action => 'et_validate_fiscal_id_textfield'
    match 'et_validate_fiscal_id_textfield/:id', :controller => 'contracting_requests', :action => 'et_validate_fiscal_id_textfield'
    match 'contracting_requests/:id/et_validate_fiscal_id_textfield/:id', :controller => 'contracting_requests', :action => 'et_validate_fiscal_id_textfield'
    match 'contracting_requests/:id/next_status', :controller => 'contracting_requests', :action => 'next_status'
    match 'contracting_requests/:id/initial_inspection', :controller => 'contracting_requests', :action => 'initial_inspection'
    match 'contracting_requests/:id/inspection_billing', :controller => 'contracting_requests', :action => 'inspection_billing'
    match 'contracting_requests/:id/initial_billing', :controller => 'contracting_requests', :action => 'initial_billing'
    match 'contracting_requests/:id/billing_instalation', :controller => 'contracting_requests', :action => 'billing_instalation'
    match 'contracting_requests/:id/instalation_subscriber', :controller => 'contracting_requests', :action => 'instalation_subscriber'
    match 'contracting_requests/:id/update_bill', :controller => 'contracting_requests', :action => 'update_bill'
    match 'contracting_requests/get_caliber/:id', :controller => 'contracting_requests', :action => 'get_caliber'
    match 'contracting_requests/update_old_subscriber/:id', :controller => 'contracting_requests', :action => 'update_old_subscriber'
    match 'contracting_requests/:id/initial_complete', :controller => 'contracting_requests', :action => 'initial_complete'
    match 'contracting_requests/:id/billing_complete', :controller => 'contracting_requests', :action => 'billing_complete'
    #Comment Route Update Server
    match 'contracting_requests/dn_update_from_invoice/:arr_invoice', :controller => 'contracting_requests', :action => 'dn_update_from_invoice'
    #
    # Prototype
    match "sale_offers/show_test", controller: "sale_offers", action: 'show_test'
    match "sale_offer_status/show_test", controller: "sale_offer_status", action: 'show_test'
    match "street_directories/show_test", controller: "street_directories", action: 'show_test'
    match "centers/show_test", controller: "centers", action: 'show_test'
    match "meters/show_test", controller: "meters", action: 'show_test'
    match "meter_models/show_test", controller: "meter_models", action: 'show_test'
    match "calibers/show_test", controller: "calibers", action: 'show_test'
    match "billing_periods/show_test", controller: "billing_periods", action: 'show_test'
    match "billing_frequencies/show_test", controller: "billing_frequencies", action: 'show_test'
    match "subscribers/show_test", controller: "subscribers", action: 'show_test'
    match "subscribers/new_invoice", controller: "subscribers", action: 'new_invoice'
    match "subscribers/show_invoice", controller: "subscribers", action: 'show_invoice'
    match "reading_types/show_test", controller: "reading_types", action: 'show_test'
    match "reading_routes/show_test", controller: "reading_routes", action: 'show_test'
    match "reading_incidences_types/show_test", controller: "reading_incidences_types", action: 'show_test'
    match "invoice_types/show_test", controller: "invoice_types", action: 'show_test'
    match "banks/show_test", controller: "banks", action: 'show_test'
    match "bank_offices/show_test", controller: "bank_offices", action: 'show_test'
    match "bank_account_classes/show_test", controller: "bank_account_classes", action: 'show_test'
    match "tariff_schemes/show_test", controller: "tariff_schemes", action: 'show_test'
    match "tariff_types/show_test", controller: "tariff_types", action: 'show_test'
    match "billable_concepts/show_test", controller: "billable_concepts", action: 'show_test'
    match "contracting_requests/show_test", controller: "contracting_requests", action: 'show_test'
    #
    #service point
    match 'service_points/update_offices_textfield_from_company/:id', :controller => 'service_points', :action => 'update_offices_textfield_from_company'
    match 'service_points/:id/update_offices_textfield_from_company/:id', :controller => 'service_points', :action => 'update_offices_textfield_from_company'
    match 'service_points/update_province_textfield_from_town/:id', :controller => 'service_points', :action => 'update_province_textfield_from_town'
    match 'service_points/:id/update_province_textfield_from_town/:id', :controller => 'service_points', :action => 'update_province_textfield_from_town'
    match 'service_points/update_province_textfield_from_zipcode/:id', :controller => 'service_points', :action => 'update_province_textfield_from_zipcode'
    match 'service_points/:id/update_province_textfield_from_zipcode/:id', :controller => 'service_points', :action => 'update_province_textfield_from_zipcode'
    match 'service_points/update_country_textfield_from_region/:id', :controller => 'service_points', :action => 'update_country_textfield_from_region'
    match 'service_points/:id/update_country_textfield_from_region/:id', :controller => 'service_points', :action => 'update_country_textfield_from_region'
    match 'service_points/update_region_textfield_from_province/:id', :controller => 'service_points', :action => 'update_region_textfield_from_province'
    match 'service_points/:id/update_region_textfield_from_province/:id', :controller => 'service_points', :action => 'update_region_textfield_from_province'
    match 'service_points/update_province_textfield_from_street_directory/:id', :controller => 'service_points', :action => 'update_province_textfield_from_street_directory'
    match 'service_points/:id/update_province_textfield_from_street_directory/:id', :controller => 'service_points', :action => 'update_province_textfield_from_street_directory'

    #Subscriber
    match 'subscribers/add_meter/:id', :controller => 'subscribers', :action => 'add_meter', :via => [:post]
    match 'subscribers/:id/add_meter/:id', :controller => 'subscribers', :action => 'add_meter', :via => [:post]
    match 'subscribers/quit_meter/:id', :controller => 'subscribers', :action => 'quit_meter'#, :via => [:post]
    match 'subscribers/:id/quit_meter/:id', :controller => 'subscribers', :action => 'quit_meter'#, :via => [:post]
    match 'subscribers/change_meter/:id', :controller => 'subscribers', :action => 'change_meter', :via => [:post]
    match 'subscribers/:id/change_meter/:id', :controller => 'subscribers', :action => 'change_meter', :via => [:post]
    match 'subscribers/:id/void/:bill_id', :controller => 'subscribers', :action => 'void', :via => [:get], as: "void_subscriber_bill"
    match 'subscribers/:id/rebilling/:bill_id', :controller => 'subscribers', :action => 'rebilling', :via => [:get], as: "rebilling_subscriber_bill"

    # Resources
    resources :clients
    resources :subscribers do
      get 'subscriber_pdf', on: :member
      post 'change_meter', on: :member
      post 'simple_bill', on: :member
      post 'update_simple', on: :member
    end
    #
    resources :centers
    resources :street_directories
    #
    resources :sale_offers
    resources :sale_offer_statuses
    #
    resources :contracting_requests do
      get 'contracting_request_pdf', on: :member
      get 'bill', on: :member
      get 'biller_pdf', on: :member
      get 'contracting_subscriber_pdf', on: :member
      resources :water_supply_contracts, except: [:index, :show, :edit, :new]
      #resources :water_supply_contracts, except: [:new]
      resources :subscribers, only: [:create, :update]
    end
    resources :water_supply_contracts
    resources :water_connection_contracts
    resources :contracting_request_types
    resources :contracting_request_statuses
    resources :contracting_request_document_types
    #
    resources :tariff_schemes do
      post 'create_pct', on: :collection
      get 'simple_edit', on: :member
    end
    resources :tariffs
    resources :tariff_types
    resources :billable_concepts
    #
    resources :meters
    resources :meter_types
    resources :meter_brands
    resources :meter_models
    resources :meter_locations
    resources :meter_owners
    resources :calibers
    #
    resources :service_points
    resources :water_connections
    resources :service_point_types
    resources :water_connection_types
    resources :service_point_locations
    resources :service_point_purposes
    #
    resources :pre_readings do
      get 'impute_readings', on: :collection
      get 'new_impute', on: :collection
      get 'to_reading', on: :collection
      get 'to_pdf', on: :collection
      get 'list', on: :collection
      #get 'new_pre_readings' on: :member
    end
    resources :readings
    resources :reading_types
    resources :reading_incidence_types
    resources :reading_routes
    match 'reading_routes/update_office_textfield_from_project/:id', :controller => 'reading_routes', :action => 'update_office_textfield_from_project'
    #
    # match 'bills/update_simple', :controller => 'bill', :action => 'update_simple'
    resources :bills do
      get 'pre_index', on: :collection
      get 'get_subscribers', on: :collection
      get 'show_consumptions', on: :collection
      get 'confirm', on: :collection
      get 'bill_supply_pdf', on: :member
      #get 'void', on: :member
      #get 'rebilling', on: :member
    end
    resources :invoices
    resources :billable_items
    resources :billing_periods
    resources :billing_frequencies
    resources :invoice_types
    resources :invoice_statuses
    resources :invoice_operations
    #
    resources :regulations
    resources :regulation_types
    #
    resources :client_payments do
      post 'cash_others', on: :collection
      post 'banks', on: :collection
      post 'fractionated', on: :collection
      post 'instalment', on: :collection
      post 'close_cash', on: :collection
      post 'confirm_bank', on: :collection
    end
    resources :payment_methods

    # Root
    root :to => 'home#index'
  end
end
