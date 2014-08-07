Ag2Tech::Engine.routes.draw do
  scope "(:locale)", :locale => /en|es/ do
    # Get
    get "home/index"

    # Routes for jQuery POSTs
    # Numbers with decimals (.) must be multiplied (by 1xxx and the same zeroes x positions) before passed as REST parameter! 
    match 'projects/pr_update_company_textfield_from_office/:id', :controller => 'projects', :action => 'pr_update_company_textfield_from_office'
    match 'pr_update_company_textfield_from_office/:id', :controller => 'projects', :action => 'pr_update_company_textfield_from_office'
    match 'projects/:id/pr_update_company_textfield_from_office/:id', :controller => 'projects', :action => 'pr_update_company_textfield_from_office'
    match 'projects/pr_update_company_and_office_textfields_from_organization/:id', :controller => 'projects', :action => 'pr_update_company_and_office_textfields_from_organization'
    match 'pr_update_company_and_office_textfields_from_organization/:id', :controller => 'projects', :action => 'pr_update_company_and_office_textfields_from_organization'
    match 'projects/:id/pr_update_company_and_office_textfields_from_organization/:id', :controller => 'projects', :action => 'pr_update_company_and_office_textfields_from_organization'
    #
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
    match 'work_orders/wo_update_description_prices_from_product_store/:product/:qty/:store', :controller => 'work_orders', :action => 'wo_update_description_prices_from_product_store'
    match 'wo_update_description_prices_from_product_store/:product/:qty/:store', :controller => 'work_orders', :action => 'wo_update_description_prices_from_product_store'
    match 'work_orders/:id/wo_update_description_prices_from_product_store/:product/:qty/:store', :controller => 'work_orders', :action => 'wo_update_description_prices_from_product_store'
    match 'work_orders/wo_update_description_prices_from_product/:product/:qty', :controller => 'work_orders', :action => 'wo_update_description_prices_from_product'
    match 'wo_update_description_prices_from_product/:product/:qty', :controller => 'work_orders', :action => 'wo_update_description_prices_from_product'
    match 'work_orders/:id/wo_update_description_prices_from_product/:product/:qty', :controller => 'work_orders', :action => 'wo_update_description_prices_from_product'
    match 'work_orders/wo_update_costs_from_worker/:worker/:hours/:project/:year', :controller => 'work_orders', :action => 'wo_update_costs_from_worker'
    match 'wo_update_costs_from_worker/:worker/:hours/:project/:year', :controller => 'work_orders', :action => 'wo_update_costs_from_worker'
    match 'work_orders/:id/wo_update_costs_from_worker/:worker/:hours/:project/:year', :controller => 'work_orders', :action => 'wo_update_costs_from_worker'
    match 'work_orders/wo_update_amount_and_costs_from_price_or_quantity/:cost/:price/:qty/:tax_type/:product', :controller => 'work_orders', :action => 'wo_update_amount_and_costs_from_price_or_quantity'
    match 'wo_update_amount_and_costs_from_price_or_quantity/:cost/:price/:qty/:tax_type/:product', :controller => 'work_orders', :action => 'wo_update_amount_and_costs_from_price_or_quantity'
    match 'work_orders/:id/wo_update_amount_and_costs_from_price_or_quantity/:cost/:price/:qty/:tax_type/:product', :controller => 'work_orders', :action => 'wo_update_amount_and_costs_from_price_or_quantity'
    match 'work_orders/wo_update_costs_from_cost_or_hours/:cost/:hours', :controller => 'work_orders', :action => 'wo_update_costs_from_cost_or_hours'
    match 'wo_update_costs_from_cost_or_hours/:cost/:hours', :controller => 'work_orders', :action => 'wo_update_costs_from_cost_or_hours'
    match 'work_orders/:id/wo_update_costs_from_cost_or_hours/:cost/:hours', :controller => 'work_orders', :action => 'wo_update_costs_from_cost_or_hours'

    # Resources
    resources :projects
    resources :charge_accounts
    resources :work_orders
    resources :work_order_labors
    resources :work_order_statuses
    resources :work_order_types
    
    # Root
    root :to => 'home#index'
  end
end
