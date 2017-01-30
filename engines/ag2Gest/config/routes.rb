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
    # report subscriber
    match 'subscriber_report', :controller => 'subscribers', :action => 'subscriber_report'
    match 'subscriber_tec_report', :controller => 'subscribers', :action => 'subscriber_tec_report'
    match 'subscriber_eco_report', :controller => 'subscribers', :action => 'subscriber_eco_report'
    # report reading
    match 'reading_report', :controller => 'readings', :action => 'reading_report'
    # report bill
    match 'bill_report', :controller => 'client_payments', :action => 'bill_report'
    match 'bill_pending_report', :controller => 'client_payments', :action => 'bill_pending_report'
    match 'bill_unpaid_report', :controller => 'client_payments', :action => 'bill_unpaid_report'
    match 'bill_charged_report', :controller => 'client_payments', :action => 'bill_charged_report'
    # report invoice
    match 'invoice_view_report', :controller => 'invoices', :action => 'invoice_view_report'
    # report client_payment
    match 'client_payment_report', :controller => 'client_payments', :action => 'client_payment_report'
    # report contracting_request
    match 'contracting_request_report', :controller => 'contracting_requests', :action => 'contracting_request_report'
    match 'contracting_request_complete_report', :controller => 'contracting_requests', :action => 'contracting_request_complete_report'
    # report meter
    match 'meter_view_report', :controller => 'meters', :action => 'meter_view_report'

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
    match "formality_management", controller: "home", action: 'formality_management'
    match "debt_claim_management", controller: "home", action: 'debt_claim_management'
    match "complaint_management", controller: "home", action: 'complaint_management'
    match "sale_offer_management", controller: "home", action: 'sale_offer_management'
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
    match 'contracting_requests/cr_find_meter/:meter', :controller => 'contracting_requests', :action => 'cr_find_meter'
    match 'contracting_requests/:id/cr_find_meter/:meter', :controller => 'contracting_requests', :action => 'cr_find_meter'
    match 'cr_find_meter/:meter', :controller => 'contracting_requests', :action => 'cr_find_meter'
    match 'contracting_requests/cr_find_subscriber/:subscriber', :controller => 'contracting_requests', :action => 'cr_find_subscriber'
    match 'contracting_requests/:id/cr_find_subscriber/:subscriber', :controller => 'contracting_requests', :action => 'cr_find_subscriber'
    match 'cr_find_subscriber/:subscriber', :controller => 'contracting_requests', :action => 'cr_find_subscriber'
    match 'contracting_requests/cr_find_service_point/:service_point', :controller => 'contracting_requests', :action => 'cr_find_service_point'
    match 'contracting_requests/:id/cr_find_service_point/:service_point', :controller => 'contracting_requests', :action => 'cr_find_service_point'
    match 'cr_find_service_point/:service_point', :controller => 'contracting_requests', :action => 'cr_find_service_point'
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
    # Service point
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
    #
    # Subscriber
    match 'subscribers/add_meter/:id', :controller => 'subscribers', :action => 'add_meter', :via => [:post]
    match 'subscribers/:id/add_meter/:id', :controller => 'subscribers', :action => 'add_meter', :via => [:post]
    match 'subscribers/quit_meter/:id', :controller => 'subscribers', :action => 'quit_meter'#, :via => [:post]
    match 'subscribers/:id/quit_meter/:id', :controller => 'subscribers', :action => 'quit_meter'#, :via => [:post]
    match 'subscribers/change_meter/:id', :controller => 'subscribers', :action => 'change_meter', :via => [:post]
    match 'subscribers/:id/change_meter/:id', :controller => 'subscribers', :action => 'change_meter', :via => [:post]
    match 'subscribers/:id/void/:bill_id', :controller => 'subscribers', :action => 'void', :via => [:get], as: "void_subscriber_bill"
    match 'subscribers/:id/rebilling/:bill_id', :controller => 'subscribers', :action => 'rebilling', :via => [:get], as: "rebilling_subscriber_bill"
    match 'subscribers/su_find_meter/:meter', :controller => 'subscribers', :action => 'su_find_meter'
    match 'subscribers/:id/su_find_meter/:meter', :controller => 'subscribers', :action => 'su_find_meter'
    match 'su_find_meter/:meter', :controller => 'subscribers', :action => 'su_find_meter'
    #
    # Commercial billing
    match 'commercial_billings/ci_generate_no/:project', :controller => 'commercial_billings', :action => 'ci_generate_no'
    match 'ci_generate_no/:project', :controller => 'commercial_billings', :action => 'ci_generate_no'
    match 'commercial_billings/:id/ci_generate_no/:project', :controller => 'commercial_billings', :action => 'ci_generate_no'
    match 'commercial_billings/ci_update_selects_from_organization/:org', :controller => 'commercial_billings', :action => 'ci_update_selects_from_organization'
    match 'ci_update_selects_from_organization/:org', :controller => 'commercial_billings', :action => 'ci_update_selects_from_organization'
    match 'commercial_billings/:id/ci_update_selects_from_organization/:org', :controller => 'commercial_billings', :action => 'ci_update_selects_from_organization'
    match 'commercial_billings/ci_update_offer_select_from_client/:client', :controller => 'commercial_billings', :action => 'ci_update_offer_select_from_client'
    match 'ci_update_offer_select_from_client/:client', :controller => 'commercial_billings', :action => 'ci_update_offer_select_from_client'
    match 'commercial_billings/:id/ci_update_offer_select_from_client/:client', :controller => 'commercial_billings', :action => 'ci_update_offer_select_from_client'
    match 'commercial_billings/ci_update_selects_from_project/:order', :controller => 'commercial_billings', :action => 'ci_update_selects_from_project'
    match 'ci_update_selects_from_project/:order', :controller => 'commercial_billings', :action => 'ci_update_selects_from_project'
    match 'commercial_billings/:id/ci_update_selects_from_project/:order', :controller => 'commercial_billings', :action => 'ci_update_selects_from_project'
    match 'commercial_billings/ci_format_number/:num', :controller => 'commercial_billings', :action => 'ci_format_number'
    match 'ci_format_number/:num', :controller => 'commercial_billings', :action => 'ci_format_number'
    match 'commercial_billings/:id/ci_format_number/:num', :controller => 'commercial_billings', :action => 'ci_format_number'
    match 'commercial_billings/ci_format_number_4/:num', :controller => 'commercial_billings', :action => 'ci_format_number_4'
    match 'ci_format_number_4/:num', :controller => 'commercial_billings', :action => 'ci_format_number_4'
    match 'commercial_billings/:id/ci_format_number_4/:num', :controller => 'commercial_billings', :action => 'ci_format_number_4'
    match 'commercial_billings/ci_item_totals/:qty/:amount/:tax/:discount_p', :controller => 'commercial_billings', :action => 'ci_item_totals'
    match 'ci_item_totals/:qty/:amount/:tax/:discount_p', :controller => 'commercial_billings', :action => 'ci_item_totals'
    match 'commercial_billings/:id/ci_item_totals/:qty/:amount/:tax/:discount_p', :controller => 'commercial_billings', :action => 'ci_item_totals'
    match 'commercial_billings/send_invoice_form/:id', :controller => 'commercial_billings', :action => 'send_invoice_form'
    match 'send_invoice_form/:id', :controller => 'commercial_billings', :action => 'send_invoice_form'
    match 'commercial_billings/:id/send_invoice_form/:id', :controller => 'commercial_billings', :action => 'send_invoice_form'
    match 'commercial_billings/ci_update_description_prices_from_product/:product/:qty/:tbl', :controller => 'commercial_billings', :action => 'ci_update_description_prices_from_product'
    match 'ci_update_description_prices_from_product/:product/:qty/:tbl', :controller => 'commercial_billings', :action => 'ci_update_description_prices_from_product'
    match 'commercial_billings/:id/ci_update_description_prices_from_product/:product/:qty/:tbl', :controller => 'commercial_billings', :action => 'ci_update_description_prices_from_product'
    match 'commercial_billings/ci_update_product_select_from_offer_item/:i', :controller => 'commercial_billings', :action => 'ci_update_product_select_from_offer_item'
    match 'ci_update_product_select_from_offer_item/:i', :controller => 'commercial_billings', :action => 'ci_update_product_select_from_offer_item'
    match 'commercial_billings/:id/ci_update_product_select_from_offer_item/:i', :controller => 'commercial_billings', :action => 'ci_update_product_select_from_offer_item'
    match 'commercial_billings/ci_update_amount_from_price_or_quantity/:price/:qty/:tax_type/:discount_p/:discount/:product/:tbl', :controller => 'commercial_billings', :action => 'ci_update_amount_from_price_or_quantity'
    match 'ci_update_amount_from_price_or_quantity/:price/:qty/:tax_type/:discount_p/:discount/:product/:tbl', :controller => 'commercial_billings', :action => 'ci_update_amount_from_price_or_quantity'
    match 'commercial_billings/:id/ci_update_amount_from_price_or_quantity/:price/:qty/:tax_type/:discount_p/:discount/:product/:tbl', :controller => 'commercial_billings', :action => 'ci_update_amount_from_price_or_quantity'
    match 'commercial_billings/ci_item_balance_check/:i/:qty', :controller => 'commercial_billings', :action => 'ci_item_balance_check'
    match 'ci_item_balance_check/:i/:qty', :controller => 'commercial_billings', :action => 'ci_item_balance_check'
    match 'commercial_billings/:id/ci_item_balance_check/:i/:qty', :controller => 'commercial_billings', :action => 'ci_item_balance_check'
    match 'commercial_billings/ci_item_totals/:qty/:amount/:tax/:discount_p', :controller => 'commercial_billings', :action => 'ci_item_totals'
    match 'ci_item_totals/:qty/:amount/:tax/:discount_p', :controller => 'commercial_billings', :action => 'ci_item_totals'
    match 'commercial_billings/:id/ci_item_totals/:qty/:amount/:tax/:discount_p', :controller => 'commercial_billings', :action => 'ci_item_totals'
    match 'commercial_billings/ci_generate_invoice/:supplier/:request/:offer_no/:offer_date', :controller => 'commercial_billings', :action => 'ci_generate_invoice'
    match 'ci_generate_invoice/:supplier/:request/:offer_no/:offer_date', :controller => 'commercial_billings', :action => 'ci_generate_invoice'
    match 'commercial_billings/:id/ci_generate_invoice/:supplier/:request/:offer_no/:offer_date', :controller => 'commercial_billings', :action => 'ci_generate_invoice'
    match 'commercial_billings/ci_current_balance/:order', :controller => 'commercial_billings', :action => 'ci_current_balance'
    match 'ci_current_balance/:order', :controller => 'commercial_billings', :action => 'ci_current_balance'
    match 'commercial_billings/:id/ci_current_balance/:order', :controller => 'commercial_billings', :action => 'ci_current_balance'

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
      post 'subrogation', on: :collection
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
    resources :tariffs do
      post 'create_pct', on: :collection
    end
    resources :tariff_types
    resources :billable_concepts
    resources :uses
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
      get 'biller_pdf', on: :member
      #get 'void', on: :member
      #get 'rebilling', on: :member
    end
    resources :invoices
    resources :billable_items
    resources :billing_periods
    resources :billing_frequencies
    resources :billing_incidence_types
    resources :invoice_types
    resources :invoice_statuses
    resources :invoice_operations
    resources :commercial_billings do
      get 'invoice_form', on: :collection
    end
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
    #
    resources :formalities
    resources :formality_types
    #
    resources :debt_claim_phases
    resources :debt_claim_statuses
    #
    resources :complaint_classes
    resources :complaint_statuses
    resources :complaint_document_types
    #
    resources :subscriber_annotation_classes

    resources :tariff_scheme_items, only: :destroy
    resources :contracted_tariffs, only: :destroy

    # Root
    root :to => 'home#index'
  end
end
