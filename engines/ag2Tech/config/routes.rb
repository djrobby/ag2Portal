Ag2Tech::Engine.routes.draw do
  scope "(:locale)", :locale => /en|es/ do
    # Get
    get "home/index"

    # Routes to Control&Tracking
    match 'ag2_tech_track' => 'ag2_tech_track#index', :as => :ag2_tech_track
    #
    # Control&Tracking
    match 'te_track_project_has_changed/:order', :controller => 'ag2_tech_track', :action => 'te_track_project_has_changed'
    #match 'te_track_family_has_changed/:order', :controller => 'ag2_tech_track', :action => 'te_track_family_has_changed'
    # Reports
    match 'project_report', :controller => 'ag2_tech_track', :action => 'project_report'
    match 'budget_report', :controller => 'ag2_tech_track', :action => 'budget_report'
    match 'work_report', :controller => 'ag2_tech_track', :action => 'work_report'

    # Routes for jQuery POSTs
    # Numbers with decimals (.) must be multiplied (by 1xxx and the same zeroes x positions) before passed as REST parameter!
    # 
    # Projects
    match 'projects/pr_update_company_textfield_from_office/:id', :controller => 'projects', :action => 'pr_update_company_textfield_from_office'
    match 'pr_update_company_textfield_from_office/:id', :controller => 'projects', :action => 'pr_update_company_textfield_from_office'
    match 'projects/:id/pr_update_company_textfield_from_office/:id', :controller => 'projects', :action => 'pr_update_company_textfield_from_office'
    match 'projects/pr_update_company_and_office_textfields_from_organization/:org', :controller => 'projects', :action => 'pr_update_company_and_office_textfields_from_organization'
    match 'pr_update_company_and_office_textfields_from_organization/:org', :controller => 'projects', :action => 'pr_update_company_and_office_textfields_from_organization'
    match 'projects/:id/pr_update_company_and_office_textfields_from_organization/:org', :controller => 'projects', :action => 'pr_update_company_and_office_textfields_from_organization'
    match 'projects/pr_generate_code/:company/:type', :controller => 'projects', :action => 'pr_generate_code'
    match 'pr_generate_code/:company/:type', :controller => 'projects', :action => 'pr_generate_code'
    match 'projects/:id/pr_generate_code/:company/:type', :controller => 'projects', :action => 'pr_generate_code'
    match 'projects/pr_update_total_and_price/:total/:price', :controller => 'projects', :action => 'pr_update_total_and_price'
    match 'pr_update_total_and_price/:total/:price', :controller => 'projects', :action => 'pr_update_total_and_price'
    match 'projects/:id/pr_update_total_and_price/:total/:price', :controller => 'projects', :action => 'pr_update_total_and_price'
    #
    # Accounts
    match 'charge_accounts/cc_generate_code/:group/:org/:prj', :controller => 'charge_accounts', :action => 'cc_generate_code'
    match 'cc_generate_code/:group/:org/:prj', :controller => 'charge_accounts', :action => 'cc_generate_code'
    match 'charge_accounts/:id/cc_generate_code/:group/:org/:prj', :controller => 'charge_accounts', :action => 'cc_generate_code'
    match 'charge_accounts/cc_update_project_textfields_from_organization/:org', :controller => 'charge_accounts', :action => 'cc_update_project_textfields_from_organization'
    match 'cc_update_project_textfields_from_organization/:org', :controller => 'charge_accounts', :action => 'cc_update_project_textfields_from_organization'
    match 'charge_accounts/:id/cc_update_project_textfields_from_organization/:org', :controller => 'charge_accounts', :action => 'cc_update_project_textfields_from_organization'
    #
    # Groups
    match 'charge_groups/cg_update_heading_textfield_from_organization/:org', :controller => 'charge_groups', :action => 'cg_update_heading_textfield_from_organization'
    match 'cg_update_heading_textfield_from_organization/:org', :controller => 'charge_groups', :action => 'cg_update_heading_textfield_from_organization'
    match 'charge_groups/:id/cg_update_heading_textfield_from_organization/:org', :controller => 'charge_groups', :action => 'cg_update_heading_textfield_from_organization'
    #
    # Work orders
    match 'work_orders/wo_update_account_textfield_from_project/:id', :controller => 'work_orders', :action => 'wo_update_account_textfield_from_project'
    match 'wo_update_account_textfield_from_project/:id', :controller => 'work_orders', :action => 'wo_update_account_textfield_from_project'
    match 'work_orders/:id/wo_update_account_textfield_from_project/:id', :controller => 'work_orders', :action => 'wo_update_account_textfield_from_project'
    match 'work_orders/wo_update_worker_select_from_area/:id', :controller => 'work_orders', :action => 'wo_update_worker_select_from_area'
    match 'wo_update_worker_select_from_area/:id', :controller => 'work_orders', :action => 'wo_update_worker_select_from_area'
    match 'work_orders/:id/wo_update_worker_select_from_area/:id', :controller => 'work_orders', :action => 'wo_update_worker_select_from_area'
    match 'work_orders/wo_update_petitioner_textfield_from_client/:id', :controller => 'work_orders', :action => 'wo_update_petitioner_textfield_from_client'
    match 'wo_update_petitioner_textfield_from_client/:id', :controller => 'work_orders', :action => 'wo_update_petitioner_textfield_from_client'
    match 'work_orders/:id/wo_update_petitioner_textfield_from_client/:id', :controller => 'work_orders', :action => 'wo_update_petitioner_textfield_from_client'
    match 'work_orders/wo_item_totals/:qty/:amount/:costs/:tax', :controller => 'work_orders', :action => 'wo_item_totals'
    match 'wo_item_totals/:qty/:amount/:costs/:tax', :controller => 'work_orders', :action => 'wo_item_totals'
    match 'work_orders/:id/wo_item_totals/:qty/:amount/:costs/:tax', :controller => 'work_orders', :action => 'wo_item_totals'
    match 'work_orders/wo_worker_totals/:hours/:costs/:count', :controller => 'work_orders', :action => 'wo_worker_totals'
    match 'wo_worker_totals/:hours/:costs/:count', :controller => 'work_orders', :action => 'wo_worker_totals'
    match 'work_orders/:id/wo_worker_totals/:hours/:costs/:count', :controller => 'work_orders', :action => 'wo_worker_totals'
    match 'work_orders/wo_tool_totals/:minutes/:costs/:count', :controller => 'work_orders', :action => 'wo_tool_totals'
    match 'wo_tool_totals/:minutes/:costs/:count', :controller => 'work_orders', :action => 'wo_tool_totals'
    match 'work_orders/:id/wo_tool_totals/:minutes/:costs/:count', :controller => 'work_orders', :action => 'wo_tool_totals'
    match 'work_orders/wo_vehicle_totals/:distance/:costs/:count', :controller => 'work_orders', :action => 'wo_vehicle_totals'
    match 'wo_vehicle_totals/:distance/:costs/:count', :controller => 'work_orders', :action => 'wo_vehicle_totals'
    match 'work_orders/:id/wo_vehicle_totals/:distance/:costs/:count', :controller => 'work_orders', :action => 'wo_vehicle_totals'
    match 'work_orders/wo_subcontractor_totals/:pct/:costs/:count', :controller => 'work_orders', :action => 'wo_subcontractor_totals'
    match 'wo_subcontractor_totals/:pct/:costs/:count', :controller => 'work_orders', :action => 'wo_subcontractor_totals'
    match 'work_orders/:id/wo_subcontractor_totals/:pct/:costs/:count', :controller => 'work_orders', :action => 'wo_subcontractor_totals'
    match 'work_orders/wo_update_description_prices_from_product/:product/:qty/:store/:tbl', :controller => 'work_orders', :action => 'wo_update_description_prices_from_product'
    match 'wo_update_description_prices_from_product/:product/:qty/:store/:tbl', :controller => 'work_orders', :action => 'wo_update_description_prices_from_product'
    match 'work_orders/:id/wo_update_description_prices_from_product/:product/:qty/:store/:tbl', :controller => 'work_orders', :action => 'wo_update_description_prices_from_product'
    match 'work_orders/wo_update_costs_from_worker/:worker/:hours/:project/:year/:tbl', :controller => 'work_orders', :action => 'wo_update_costs_from_worker'
    match 'wo_update_costs_from_worker/:worker/:hours/:project/:year/:tbl', :controller => 'work_orders', :action => 'wo_update_costs_from_worker'
    match 'work_orders/:id/wo_update_costs_from_worker/:worker/:hours/:project/:year/:tbl', :controller => 'work_orders', :action => 'wo_update_costs_from_worker'
    match 'work_orders/wo_update_costs_from_tool/:tool/:minutes/:tbl', :controller => 'work_orders', :action => 'wo_update_costs_from_tool'
    match 'wo_update_costs_from_tool/:tool/:minutes/:tbl', :controller => 'work_orders', :action => 'wo_update_costs_from_tool'
    match 'work_orders/:id/wo_update_costs_from_tool/:tool/:minutes/:tbl', :controller => 'work_orders', :action => 'wo_update_costs_from_tool'
    match 'work_orders/wo_update_costs_from_vehicle/:vehicle/:distance', :controller => 'work_orders', :action => 'wo_update_costs_from_vehicle'
    match 'wo_update_costs_from_vehicle/:vehicle/:distance', :controller => 'work_orders', :action => 'wo_update_costs_from_vehicle'
    match 'work_orders/:id/wo_update_costs_from_vehicle/:vehicle/:distance', :controller => 'work_orders', :action => 'wo_update_costs_from_vehicle'
    match 'work_orders/wo_update_orders_costs_from_supplier/:supplier/:pct/:tbl', :controller => 'work_orders', :action => 'wo_update_orders_costs_from_supplier'
    match 'wo_update_orders_costs_from_supplier/:supplier/:pct/:tbl', :controller => 'work_orders', :action => 'wo_update_orders_costs_from_supplier'
    match 'work_orders/:id/wo_update_orders_costs_from_supplier/:supplier/:pct/:tbl', :controller => 'work_orders', :action => 'wo_update_orders_costs_from_supplier'
    match 'work_orders/wo_update_costs_from_purchase_order/:order/:pct/:tbl', :controller => 'work_orders', :action => 'wo_update_costs_from_purchase_order'
    match 'wo_update_costs_from_purchase_order/:order/:pct/:tbl', :controller => 'work_orders', :action => 'wo_update_costs_from_purchase_order'
    match 'work_orders/:id/wo_update_costs_from_purchase_order/:order/:pct/:tbl', :controller => 'work_orders', :action => 'wo_update_costs_from_purchase_order'
    match 'work_orders/wo_update_amount_and_costs_from_price_or_quantity/:cost/:price/:qty/:tax_type/:product/:tbl', :controller => 'work_orders', :action => 'wo_update_amount_and_costs_from_price_or_quantity'
    match 'wo_update_amount_and_costs_from_price_or_quantity/:cost/:price/:qty/:tax_type/:product/:tbl', :controller => 'work_orders', :action => 'wo_update_amount_and_costs_from_price_or_quantity'
    match 'work_orders/:id/wo_update_amount_and_costs_from_price_or_quantity/:cost/:price/:qty/:tax_type/:product/:tbl', :controller => 'work_orders', :action => 'wo_update_amount_and_costs_from_price_or_quantity'
    match 'work_orders/wo_update_costs_from_cost_or_hours/:cost/:hours/:tbl', :controller => 'work_orders', :action => 'wo_update_costs_from_cost_or_hours'
    match 'wo_update_costs_from_cost_or_hours/:cost/:hours/:tbl', :controller => 'work_orders', :action => 'wo_update_costs_from_cost_or_hours'
    match 'work_orders/:id/wo_update_costs_from_cost_or_hours/:cost/:hours/:tbl', :controller => 'work_orders', :action => 'wo_update_costs_from_cost_or_hours'
    match 'work_orders/wo_update_costs_from_cost_or_minutes/:cost/:minutes/:tbl', :controller => 'work_orders', :action => 'wo_update_costs_from_cost_or_minutes'
    match 'wo_update_costs_from_cost_or_minutes/:cost/:minutes/:tbl', :controller => 'work_orders', :action => 'wo_update_costs_from_cost_or_minutes'
    match 'work_orders/:id/wo_update_costs_from_cost_or_minutes/:cost/:minutes/:tbl', :controller => 'work_orders', :action => 'wo_update_costs_from_cost_or_minutes'
    match 'work_orders/wo_update_costs_from_cost_or_distance/:cost/:distance', :controller => 'work_orders', :action => 'wo_update_costs_from_cost_or_distance'
    match 'wo_update_costs_from_cost_or_distance/:cost/:distance', :controller => 'work_orders', :action => 'wo_update_costs_from_cost_or_distance'
    match 'work_orders/:id/wo_update_costs_from_cost_or_distance/:cost/:distance', :controller => 'work_orders', :action => 'wo_update_costs_from_cost_or_distance'
    match 'work_orders/wo_update_costs_from_cost_or_enforcement_pct/:cost/:pct/:tbl', :controller => 'work_orders', :action => 'wo_update_costs_from_cost_or_enforcement_pct'
    match 'wo_update_costs_from_cost_or_enforcement_pct/:cost/:pct/:tbl', :controller => 'work_orders', :action => 'wo_update_costs_from_cost_or_enforcement_pct'
    match 'work_orders/:id/wo_update_costs_from_cost_or_enforcement_pct/:cost/:pct/:tbl', :controller => 'work_orders', :action => 'wo_update_costs_from_cost_or_enforcement_pct'
    match 'work_orders/wo_update_project_textfields_from_organization/:org', :controller => 'work_orders', :action => 'wo_update_project_textfields_from_organization'
    match 'wo_update_project_textfields_from_organization/:org', :controller => 'work_orders', :action => 'wo_update_project_textfields_from_organization'
    match 'work_orders/:id/wo_update_project_textfields_from_organization/:org', :controller => 'work_orders', :action => 'wo_update_project_textfields_from_organization'
    match 'work_orders/wo_generate_no/:project', :controller => 'work_orders', :action => 'wo_generate_no'
    match 'wo_generate_no/:project', :controller => 'work_orders', :action => 'wo_generate_no'
    match 'work_orders/:id/wo_generate_no/:project', :controller => 'work_orders', :action => 'wo_generate_no'
    #
    # Headings
    match 'budget_headings/bh_update_textfields_to_uppercase/:name', :controller => 'budget_headings', :action => 'bh_update_textfields_to_uppercase'
    match 'bh_update_textfields_to_uppercase/:name', :controller => 'budget_headings', :action => 'bh_update_textfields_to_uppercase'
    match 'budget_headings/:id/bh_update_textfields_to_uppercase/:name', :controller => 'budget_headings', :action => 'bh_update_textfields_to_uppercase'
    #
    # Tools
    match 'tools/tl_update_company_textfield_from_office/:id', :controller => 'tools', :action => 'tl_update_company_textfield_from_office'
    match 'tl_update_company_textfield_from_office/:id', :controller => 'tools', :action => 'tl_update_company_textfield_from_office'
    match 'tools/:id/tl_update_company_textfield_from_office/:id', :controller => 'tools', :action => 'tl_update_company_textfield_from_office'
    match 'tools/tl_update_company_and_office_textfields_from_organization/:org', :controller => 'tools', :action => 'tl_update_company_and_office_textfields_from_organization'
    match 'tl_update_company_and_office_textfields_from_organization/:org', :controller => 'tools', :action => 'tl_update_company_and_office_textfields_from_organization'
    match 'tools/:id/tl_update_company_and_office_textfields_from_organization/:org', :controller => 'tools', :action => 'tl_update_company_and_office_textfields_from_organization'
    match 'tools/tl_update_name_textfield_from_product/:product', :controller => 'tools', :action => 'tl_update_name_textfield_from_product'
    match 'tl_update_name_textfield_from_product/:product', :controller => 'tools', :action => 'tl_update_name_textfield_from_product'
    match 'tools/:id/tl_update_name_textfield_from_product/:product', :controller => 'tools', :action => 'tl_update_name_textfield_from_product'
    match 'tools/tl_update_cost/:cost', :controller => 'tools', :action => 'tl_update_cost'
    match 'tl_update_cost/:cost', :controller => 'tools', :action => 'tl_update_cost'
    match 'tools/:id/tl_update_cost/:cost', :controller => 'tools', :action => 'tl_update_cost'
    #
    # Vehicles
    match 'vehicles/ve_update_company_textfield_from_office/:id', :controller => 'vehicles', :action => 've_update_company_textfield_from_office'
    match 've_update_company_textfield_from_office/:id', :controller => 'vehicles', :action => 've_update_company_textfield_from_office'
    match 'vehicles/:id/ve_update_company_textfield_from_office/:id', :controller => 'vehicles', :action => 've_update_company_textfield_from_office'
    match 'vehicles/ve_update_company_and_office_textfields_from_organization/:org', :controller => 'vehicles', :action => 've_update_company_and_office_textfields_from_organization'
    match 've_update_company_and_office_textfields_from_organization/:org', :controller => 'vehicles', :action => 've_update_company_and_office_textfields_from_organization'
    match 'vehicles/:id/ve_update_company_and_office_textfields_from_organization/:org', :controller => 'vehicles', :action => 've_update_company_and_office_textfields_from_organization'
    match 'vehicles/ve_update_name_textfield_from_product/:product', :controller => 'vehicles', :action => 've_update_name_textfield_from_product'
    match 've_update_name_textfield_from_product/:product', :controller => 'vehicles', :action => 've_update_name_textfield_from_product'
    match 'vehicles/:id/ve_update_name_textfield_from_product/:product', :controller => 'vehicles', :action => 've_update_name_textfield_from_product'
    match 'vehicles/ve_update_cost/:cost', :controller => 'vehicles', :action => 've_update_cost'
    match 've_update_cost/:cost', :controller => 'vehicles', :action => 've_update_cost'
    match 'vehicles/:id/ve_update_cost/:cost', :controller => 'vehicles', :action => 've_update_cost'
    #
    # Ratios
    match 'ratios/ra_generate_code/:group/:org', :controller => 'ratios', :action => 'ra_generate_code'
    match 'ra_generate_code/:group/:org', :controller => 'ratios', :action => 'ra_generate_code'
    match 'ratios/:id/ra_generate_code/:group/:org', :controller => 'ratios', :action => 'ra_generate_code'
    match 'ratios/ra_update_group_from_organization/:org', :controller => 'ratios', :action => 'ra_update_group_from_organization'
    match 'ra_update_group_from_organization/:org', :controller => 'ratios', :action => 'ra_update_group_from_organization'
    match 'ratios/:id/ra_update_group_from_organization/:org', :controller => 'ratios', :action => 'ra_update_group_from_organization'
    #
    # Budgets
    match 'budgets/bu_generate_no/:project/:period', :controller => 'budgets', :action => 'bu_generate_no'
    match 'bu_generate_no/:project/:period', :controller => 'budgets', :action => 'bu_generate_no'
    match 'budgets/:id/bu_generate_no/:project/:period', :controller => 'budgets', :action => 'bu_generate_no'
    match 'budgets/bu_update_project_textfield_from_organization/:order', :controller => 'budgets', :action => 'bu_update_project_textfield_from_organization'
    match 'bu_update_project_textfield_from_organization/:order', :controller => 'budgets', :action => 'bu_update_project_textfield_from_organization'
    match 'budgets/:id/bu_update_project_textfield_from_organization/:order', :controller => 'budgets', :action => 'bu_update_project_textfield_from_organization'
    match 'budgets/bu_update_account_textfields_from_project/:order', :controller => 'budgets', :action => 'bu_update_account_textfields_from_project'
    match 'bu_update_account_textfields_from_project/:order', :controller => 'budgets', :action => 'bu_update_account_textfields_from_project'
    match 'budgets/:id/bu_update_account_textfields_from_project/:order', :controller => 'budgets', :action => 'bu_update_account_textfields_from_project'
    match 'budgets/bu_update_corrected/:cor/:tbl', :controller => 'budgets', :action => 'bu_update_corrected'
    match 'bu_update_corrected/:cor/:tbl', :controller => 'budgets', :action => 'bu_update_corrected'
    match 'budgets/:id/bu_update_corrected/:cor/:tbl', :controller => 'budgets', :action => 'bu_update_corrected'
    match 'budgets/bu_update_annual/:m01/:m02/:m03/:m04/:m05/:m06/:m07/:m08/:m09/:m10/:m11/:m12/:tbl', :controller => 'budgets', :action => 'bu_update_annual'
    match 'bu_update_annual/:m01/:m02/:m03/:m04/:m05/:m06/:m07/:m08/:m09/:m10/:m11/:m12/:tbl', :controller => 'budgets', :action => 'bu_update_annual'
    match 'budgets/:id/bu_update_annual/:m01/:m02/:m03/:m04/:m05/:m06/:m07/:m08/:m09/:m10/:m11/:m12/:tbl', :controller => 'budgets', :action => 'bu_update_annual'
    match 'budgets/bu_item_totals/:m01/:m02/:m03/:m04/:m05/:m06/:m07/:m08/:m09/:m10/:m11/:m12/:anu/:cor', :controller => 'budgets', :action => 'bu_item_totals'
    match 'bu_item_totals/:m01/:m02/:m03/:m04/:m05/:m06/:m07/:m08/:m09/:m10/:m11/:m12/:anu/:cor', :controller => 'budgets', :action => 'bu_item_totals'
    match 'budgets/:id/bu_item_totals/:m01/:m02/:m03/:m04/:m05/:m06/:m07/:m08/:m09/:m10/:m11/:m12/:anu/:cor', :controller => 'budgets', :action => 'bu_item_totals'
    match 'budgets/bu_new/:project/:period/:budget', :controller => 'budgets', :action => 'bu_new'
    match 'bu_new/:project/:period/:budget', :controller => 'budgets', :action => 'bu_new'
    match 'budgets/:id/bu_new/:project/:period/:budget', :controller => 'budgets', :action => 'bu_new'

    # Resources
    resources :projects
    resources :charge_accounts
    resources :charge_groups
    resources :work_orders do
      get 'work_order_form', on: :collection
      get 'work_order_form_empty', on: :collection
    end
    resources :work_order_labors
    resources :work_order_statuses
    resources :work_order_types
    resources :budget_periods
    resources :budget_headings
    resources :budgets
    resources :tools
    resources :vehicles
    resources :ratios
    resources :ratio_groups
    
    # Root
    root :to => 'home#index'
  end
end
