Ag2Gest::Engine.routes.draw do
  scope "(:locale)", :locale => /en|es/ do
    # Get
    get "home/index"

    # Routes to import

    # Routes to export
    match 'bills_to_file' => 'bills_to_files#index', :as => :bills_to_file
    match 'export_bills', :controller => 'bills_to_files', :action => 'export_bills'
    match 'export_ebills', :controller => 'bills_to_files', :action => 'export_ebills'

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
    #report cash_desk_closing
    match 'close_cash_report', :controller => 'cash_desk_closings', :action => 'close_cash_report'

    # Routes for jQuery POSTs
    #
    # Contract_Templates
    match 'contract_templates/update_province_textfield_from_town/:id', :controller => 'contract_templates', :action => 'update_province_textfield_from_town'
    match 'contract_templates/:id/update_province_textfield_from_town/:id', :controller => 'contract_templates', :action => 'update_province_textfield_from_town'
    match 'contract_templates/update_country_textfield_from_region/:id', :controller => 'contract_templates', :action => 'update_country_textfield_from_region'
    match 'contract_templates/:id/update_country_textfield_from_region/:id', :controller => 'contract_templates', :action => 'update_country_textfield_from_region'
    match 'contract_templates/update_region_textfield_from_province/:id', :controller => 'contract_templates', :action => 'update_region_textfield_from_province'
    match 'contract_templates/:id/update_region_textfield_from_province/:id', :controller => 'contract_templates', :action => 'update_region_textfield_from_province'
    # Clients
    match 'clients/update_province_textfield_from_town/:id', :controller => 'clients', :action => 'update_province_textfield_from_town'
    match 'clients/:id/update_province_textfield_from_town/:id', :controller => 'clients', :action => 'update_province_textfield_from_town'
    match 'clients/check_client_depent_subscribers/:id', :controller => 'clients', :action => 'check_client_depent_subscribers'
    match 'clients/:id/check_client_depent_subscribers/:id', :controller => 'clients', :action => 'check_client_depent_subscribers'
    match 'clients/update_province_textfield_from_zipcode/:id', :controller => 'clients', :action => 'update_province_textfield_from_zipcode'
    match 'clients/:id/update_province_textfield_from_zipcode/:id', :controller => 'clients', :action => 'update_province_textfield_from_zipcode'
    match 'clients/update_country_textfield_from_region/:id', :controller => 'clients', :action => 'update_country_textfield_from_region'
    match 'clients/:id/update_country_textfield_from_region/:id', :controller => 'clients', :action => 'update_country_textfield_from_region'
    match 'clients/update_region_textfield_from_province/:id', :controller => 'clients', :action => 'update_region_textfield_from_province'
    match 'clients/:id/update_region_textfield_from_province/:id', :controller => 'clients', :action => 'update_region_textfield_from_province'
    match 'clients/cl_validate_fiscal_id_textfield/:id', :controller => 'clients', :action => 'cl_validate_fiscal_id_textfield'
    match 'cl_validate_fiscal_id_textfield/:id', :controller => 'clients', :action => 'cl_validate_fiscal_id_textfield'
    match 'clients/:id/cl_validate_fiscal_id_textfield/:id', :controller => 'clients', :action => 'cl_validate_fiscal_id_textfield'
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
    match 'contracting_requests/:id/complete_status', :controller => 'contracting_requests', :action => 'complete_status'
    match 'contracting_requests/:id/initial_inspection', :controller => 'contracting_requests', :action => 'initial_inspection'
    match 'contracting_requests/:id/inspection_billing', :controller => 'contracting_requests', :action => 'inspection_billing'
    match 'contracting_requests/:id/inspection_billing_cancellation', :controller => 'contracting_requests', :action => 'inspection_billing_cancellation'
    match 'contracting_requests/:id/initial_billing', :controller => 'contracting_requests', :action => 'initial_billing'
    match 'contracting_requests/:id/ot_cancellation', :controller => 'contracting_requests', :action => 'ot_cancellation'
    match 'contracting_requests/:id/ot_installation', :controller => 'contracting_requests', :action => 'ot_installation'
    match 'contracting_requests/:id/initial_billing_cancellation', :controller => 'contracting_requests', :action => 'initial_billing_cancellation'
    match 'contracting_requests/:id/billing_instalation', :controller => 'contracting_requests', :action => 'billing_instalation'
    match 'contracting_requests/:id/billing_instalation_cancellation', :controller => 'contracting_requests', :action => 'billing_instalation_cancellation'
    match 'contracting_requests/:id/new_subscriber_cancellation', :controller => 'contracting_requests', :action => 'new_subscriber_cancellation'
    match 'contracting_requests/:id/instalation_subscriber', :controller => 'contracting_requests', :action => 'instalation_subscriber'
    match 'contracting_requests/:id/update_bill', :controller => 'contracting_requests', :action => 'update_bill'
    match 'contracting_requests/get_caliber/:id', :controller => 'contracting_requests', :action => 'get_caliber'
    match 'contracting_requests/update_old_subscriber/:id', :controller => 'contracting_requests', :action => 'update_old_subscriber'
    match 'contracting_requests/:id/initial_complete', :controller => 'contracting_requests', :action => 'initial_complete'
    match 'contracting_requests/:id/billing_complete', :controller => 'contracting_requests', :action => 'billing_complete'
    #Comment Route Update Server
    # match 'contracting_requests/dn_update_from_invoice/:arr_invoice', :controller => 'contracting_requests', :action => 'dn_update_from_invoice'
    match 'contracting_requests/cr_find_meter/:meter', :controller => 'contracting_requests', :action => 'cr_find_meter'
    match 'contracting_requests/:id/cr_find_meter/:meter', :controller => 'contracting_requests', :action => 'cr_find_meter'
    match 'cr_find_meter/:meter', :controller => 'contracting_requests', :action => 'cr_find_meter'
    match 'contracting_requests/cr_find_subscriber/:subscriber', :controller => 'contracting_requests', :action => 'cr_find_subscriber'
    match 'contracting_requests/:id/cr_find_subscriber/:subscriber', :controller => 'contracting_requests', :action => 'cr_find_subscriber'
    match 'cr_find_subscriber/:subscriber', :controller => 'contracting_requests', :action => 'cr_find_subscriber'
    match 'contracting_requests/cr_find_service_point/:service_point', :controller => 'contracting_requests', :action => 'cr_find_service_point'
    match 'contracting_requests/:id/cr_find_service_point/:service_point', :controller => 'contracting_requests', :action => 'cr_find_service_point'
    match 'cr_find_service_point/:service_point', :controller => 'contracting_requests', :action => 'cr_find_service_point'
    match 'contracting_requests/update_tariff_type_select_from_billing_concept/:billable_concept_ids', :controller => 'contracting_requests', :action => 'update_tariff_type_select_from_billing_concept'
    match 'contracting_requests/:id/update_tariff_type_select_from_billing_concept/:billable_concept_ids', :controller => 'contracting_requests', :action => 'update_tariff_type_select_from_billing_concept'
    match 'update_tariff_type_select_from_billing_concept/:billable_concept_ids', :controller => 'contracting_requests', :action => 'update_tariff_type_select_from_billing_concept'
    match 'contracting_requests/update_tariff_type_select_from_billing_concept/:billable_concept_ids/:use_ids', :controller => 'contracting_requests', :action => 'update_tariff_type_select_from_billing_concept'
    match 'contracting_requests/:id/update_tariff_type_select_from_billing_concept/:billable_concept_ids/:use_ids', :controller => 'contracting_requests', :action => 'update_tariff_type_select_from_billing_concept'
    match 'update_tariff_type_select_from_billing_concept/:billable_concept_ids/:use_ids', :controller => 'contracting_requests', :action => 'update_tariff_type_select_from_billing_concept'
    match 'contracting_requests/serpoint_generate_no/:id', :controller => 'contracting_requests', :action => 'serpoint_generate_no'
    match 'serpoint_generate_no/:id', :controller => 'service_points', :action => 'contracting_requests'
    match 'contracting_requests/:id/serpoint_generate_no/:id', :controller => 'contracting_requests', :action => 'serpoint_generate_no'
    #
    # Tariff
    match 'tariffs/update_billable_concept_select_from_project/:project_ids', :controller => 'tariffs', :action => 'update_billable_concept_select_from_project'
    match 'tariffs/:id/update_billable_concept_select_from_project/:project_ids', :controller => 'tariffs', :action => 'update_billable_concept_select_from_project'
    match 'update_billable_concept_select_from_project/:project_ids', :controller => 'tariffs', :action => 'update_billable_concept_select_from_project'
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
    match 'service_points/serpoint_generate_no/:id', :controller => 'service_points', :action => 'serpoint_generate_no'
    match 'serpoint_generate_no/:id', :controller => 'service_points', :action => 'serpoint_generate_no'
    match 'service_points/:id/serpoint_generate_no/:id', :controller => 'service_points', :action => 'serpoint_generate_no'
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
    match 'subscribers/:id/add_bank_account', :controller => 'subscribers', :action => 'add_bank_account', :via => [:post], as: "add_bank_account"
    match 'subscribers/su_check_iban/:country/:dc/:bank/:office/:account', :controller => 'subscribers', :action => 'su_check_iban'
    match 'su_check_iban/:country/:dc/:bank/:office/:account', :controller => 'subscribers', :action => 'su_check_iban'
    match 'subscribers/:id/su_check_iban/:country/:dc/:bank/:office/:account', :controller => 'subscribers', :action => 'su_check_iban'
    #
    # Commercial billing
    match 'commercial_billings/ci_generate_no/:project', :controller => 'commercial_billings', :action => 'ci_generate_no'
    match 'ci_generate_no/:project', :controller => 'commercial_billings', :action => 'ci_generate_no'
    match 'commercial_billings/:id/ci_generate_no/:project', :controller => 'commercial_billings', :action => 'ci_generate_no'
    match 'commercial_billings/ci_update_selects_from_organization/:org', :controller => 'commercial_billings', :action => 'ci_update_selects_from_organization'
    match 'ci_update_selects_from_organization/:org', :controller => 'commercial_billings', :action => 'ci_update_selects_from_organization'
    match 'commercial_billings/:id/ci_update_selects_from_organization/:org', :controller => 'commercial_billings', :action => 'ci_update_selects_from_organization'
    match 'commercial_billings/ci_update_product_select_from_organization/:org', :controller => 'commercial_billings', :action => 'ci_update_product_select_from_organization'
    match 'ci_update_product_select_from_organization/:org', :controller => 'commercial_billings', :action => 'ci_update_product_select_from_organization'
    match 'commercial_billings/:id/ci_update_product_select_from_organization/:org', :controller => 'commercial_billings', :action => 'ci_update_product_select_from_organization'
    match 'commercial_billings/ci_update_offer_select_from_client/:client', :controller => 'commercial_billings', :action => 'ci_update_offer_select_from_client'
    match 'ci_update_offer_select_from_client/:client', :controller => 'commercial_billings', :action => 'ci_update_offer_select_from_client'
    match 'commercial_billings/:id/ci_update_offer_select_from_client/:client', :controller => 'commercial_billings', :action => 'ci_update_offer_select_from_client'
    match 'commercial_billings/ci_update_selects_from_offer/:o', :controller => 'commercial_billings', :action => 'ci_update_selects_from_offer'
    match 'ci_update_selects_from_offer/:o', :controller => 'commercial_billings', :action => 'ci_update_selects_from_offer'
    match 'commercial_billings/:id/ci_update_selects_from_offer/:o', :controller => 'commercial_billings', :action => 'ci_update_selects_from_offer'
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
    match 'commercial_billings/ci_generate_invoice/:client/:offer/:offer_date', :controller => 'commercial_billings', :action => 'ci_generate_invoice'
    match 'ci_generate_invoice/:client/:offer/:offer_date', :controller => 'commercial_billings', :action => 'ci_generate_invoice'
    match 'commercial_billings/:id/ci_generate_invoice/:client/:offer/:offer_date', :controller => 'commercial_billings', :action => 'ci_generate_invoice'
    match 'commercial_billings/ci_current_balance/:order', :controller => 'commercial_billings', :action => 'ci_current_balance'
    match 'ci_current_balance/:order', :controller => 'commercial_billings', :action => 'ci_current_balance'
    match 'commercial_billings/:id/ci_current_balance/:order', :controller => 'commercial_billings', :action => 'ci_current_balance'
    #
    # Sale offers
    match 'sale_offers/so_generate_no/:project', :controller => 'sale_offers', :action => 'so_generate_no'
    match 'so_generate_no/:project', :controller => 'sale_offers', :action => 'so_generate_no'
    match 'sale_offers/:id/so_generate_no/:project', :controller => 'sale_offers', :action => 'so_generate_no'
    match 'sale_offers/so_update_selects_from_organization/:org', :controller => 'sale_offers', :action => 'so_update_selects_from_organization'
    match 'so_update_selects_from_organization/:org', :controller => 'sale_offers', :action => 'so_update_selects_from_organization'
    match 'sale_offers/:id/so_update_selects_from_organization/:org', :controller => 'sale_offers', :action => 'so_update_selects_from_organization'
    match 'sale_offers/so_update_product_select_from_organization/:org', :controller => 'sale_offers', :action => 'so_update_product_select_from_organization'
    match 'so_update_product_select_from_organization/:org', :controller => 'sale_offers', :action => 'so_update_product_select_from_organization'
    match 'sale_offers/:id/so_update_product_select_from_organization/:org', :controller => 'sale_offers', :action => 'so_update_product_select_from_organization'
    match 'sale_offers/so_update_selects_from_project/:project', :controller => 'sale_offers', :action => 'so_update_selects_from_project'
    match 'so_update_selects_from_project/:project', :controller => 'sale_offers', :action => 'so_update_selects_from_project'
    match 'sale_offers/:id/so_update_selects_from_project/:project', :controller => 'sale_offers', :action => 'so_update_selects_from_project'
    match 'sale_offers/so_update_request_select_from_client/:client/:project', :controller => 'sale_offers', :action => 'so_update_request_select_from_client'
    match 'so_update_request_select_from_client/:client/:project', :controller => 'sale_offers', :action => 'so_update_request_select_from_client'
    match 'sale_offers/:id/so_update_request_select_from_client/:client/:project', :controller => 'sale_offers', :action => 'so_update_request_select_from_client'
    match 'sale_offers/so_update_selects_from_order/:order', :controller => 'sale_offers', :action => 'so_update_selects_from_order'
    match 'so_update_selects_from_order/:order', :controller => 'sale_offers', :action => 'so_update_selects_from_order'
    match 'sale_offers/:id/so_update_selects_from_order/:order', :controller => 'sale_offers', :action => 'so_update_selects_from_order'
    match 'sale_offers/ci_format_number/:num', :controller => 'sale_offers', :action => 'ci_format_number'
    match 'ci_format_number/:num', :controller => 'sale_offers', :action => 'ci_format_number'
    match 'sale_offers/:id/ci_format_number/:num', :controller => 'sale_offers', :action => 'ci_format_number'
    match 'sale_offers/ci_format_number_4/:num', :controller => 'sale_offers', :action => 'ci_format_number_4'
    match 'ci_format_number_4/:num', :controller => 'sale_offers', :action => 'ci_format_number_4'
    match 'sale_offers/:id/ci_format_number_4/:num', :controller => 'sale_offers', :action => 'ci_format_number_4'
    match 'sale_offers/ci_item_totals/:qty/:amount/:tax/:discount_p', :controller => 'sale_offers', :action => 'ci_item_totals'
    match 'ci_item_totals/:qty/:amount/:tax/:discount_p', :controller => 'sale_offers', :action => 'ci_item_totals'
    match 'sale_offers/:id/ci_item_totals/:qty/:amount/:tax/:discount_p', :controller => 'sale_offers', :action => 'ci_item_totals'
    match 'sale_offers/send_sale_offer_form/:id', :controller => 'sale_offers', :action => 'send_sale_offer_form'
    match 'send_sale_offer_form/:id', :controller => 'sale_offers', :action => 'send_sale_offer_form'
    match 'sale_offers/:id/send_sale_offer_form/:id', :controller => 'sale_offers', :action => 'send_sale_offer_form'
    match 'sale_offers/so_update_description_prices_from_product/:product/:qty/:tbl', :controller => 'sale_offers', :action => 'so_update_description_prices_from_product'
    match 'so_update_description_prices_from_product/:product/:qty/:tbl', :controller => 'sale_offers', :action => 'so_update_description_prices_from_product'
    match 'sale_offers/:id/so_update_description_prices_from_product/:product/:qty/:tbl', :controller => 'sale_offers', :action => 'so_update_description_prices_from_product'
    match 'sale_offers/so_update_amount_from_price_or_quantity/:price/:qty/:tax_type/:discount_p/:discount/:product/:tbl', :controller => 'sale_offers', :action => 'so_update_amount_from_price_or_quantity'
    match 'so_update_amount_from_price_or_quantity/:price/:qty/:tax_type/:discount_p/:discount/:product/:tbl', :controller => 'sale_offers', :action => 'so_update_amount_from_price_or_quantity'
    match 'sale_offers/:id/so_update_amount_from_price_or_quantity/:price/:qty/:tax_type/:discount_p/:discount/:product/:tbl', :controller => 'sale_offers', :action => 'so_update_amount_from_price_or_quantity'
    match 'sale_offers/so_item_totals/:qty/:amount/:tax/:discount_p', :controller => 'sale_offers', :action => 'so_item_totals'
    match 'so_item_totals/:qty/:amount/:tax/:discount_p', :controller => 'sale_offers', :action => 'so_item_totals'
    match 'sale_offers/:id/so_item_totals/:qty/:amount/:tax/:discount_p', :controller => 'sale_offers', :action => 'so_item_totals'
    match 'sale_offers/so_update_approval_date', :controller => 'sale_offers', :action => 'so_update_approval_date'
    match 'so_update_approval_date', :controller => 'sale_offers', :action => 'so_update_approval_date'
    match 'sale_offers/:id/so_update_approval_date', :controller => 'sale_offers', :action => 'so_update_approval_date'
    #
    # Client payments
    match 'client_payments/cp_format_number/:num', :controller => 'client_payments', :action => 'cp_format_number'
    match 'cp_format_number/:num', :controller => 'client_payments', :action => 'cp_format_number'
    match 'client_payments/:id/cp_format_number/:num', :controller => 'client_payments', :action => 'cp_format_number'
    match 'client_payments/cp_format_number_4/:num', :controller => 'client_payments', :action => 'cp_format_number_4'
    match 'cp_format_number_4/:num', :controller => 'client_payments', :action => 'cp_format_number_4'
    match 'client_payments/:id/cp_format_number_4/:num', :controller => 'client_payments', :action => 'cp_format_number_4'

    # Resources
    resources :clients
    resources :subscribers do
      get 'subscriber_pdf', on: :member
      post 'change_meter', on: :member
      post 'simple_bill', on: :member
      post 'update_simple', on: :member
      post 'update_tariffs', on: :member
    end
    #
    resources :centers
    resources :street_directories
    #
    resources :sale_offers do
      get 'sale_offer_form', on: :collection
    end
    resources :sale_offer_statuses
    #
    resources :contracting_requests do
      get 'contracting_request_pdf', on: :member
      get 'contract_pdf', on: :member
      get 'sepa_pdf', on: :member
      get 'bill', on: :member
      get 'bill_cancellation', on: :member
      get 'biller_pdf', on: :member
      get 'refresh_status', on: :member
      get 'biller_contract_pdf', on: :member
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
    resources :contract_templates
    resources :contract_template_terms
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
      get 'list_q', on: :collection
      get 'show_list', on: :collection
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
      get 'biller_contract_pdf', on: :member
      get 'status_prebills', on: :collection
      get 'status_confirm', on: :collection
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
      get 'invoice_form', on: :member
    end
    resources :bills_to_files
    #
    resources :regulations
    resources :regulation_types
    #
    resources :client_payments do
      post 'cash', on: :collection
      post 'banks', on: :collection
      post 'fractionate', on: :collection
      post 'charge_instalment', on: :collection
      post 'others', on: :collection
      post 'close_cash', on: :collection
      post 'confirm_bank', on: :collection
      get 'payment_receipt', on: :member
      post 'cash_to_pending', on: :collection
      post 'bank_to_pending', on: :collection
      post 'bank_to_order', on: :collection
      post 'bank_from_return', on: :collection
    end
    resources :payment_methods
    #
    resources :cash_desk_closings do
      get 'close_cash_form', on: :member
    end
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
