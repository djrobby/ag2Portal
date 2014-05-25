Ag2Tech::Engine.routes.draw do
  scope "(:locale)", :locale => /en|es/ do
    # Get
    get "home/index"

    # Routes for jQuery POSTs
    match 'projects/pr_update_company_textfield_from_office/:id', :controller => 'projects', :action => 'pr_update_company_textfield_from_office'
    match 'pr_update_company_textfield_from_office/:id', :controller => 'projects', :action => 'pr_update_company_textfield_from_office'
    match 'projects/:id/pr_update_company_textfield_from_office/:id', :controller => 'projects', :action => 'pr_update_company_textfield_from_office'
    #
    match 'work_orders/wo_update_account_textfield_from_project/:id', :controller => 'work_orders', :action => 'wo_update_account_textfield_from_project'
    match 'wo_update_account_textfield_from_project/:id', :controller => 'work_orders', :action => 'wo_update_account_textfield_from_project'
    match 'work_orders/:id/wo_update_account_textfield_from_project/:id', :controller => 'work_orders', :action => 'wo_update_account_textfield_from_project'
    match 'work_orders/wo_update_worker_select_from_area/:id', :controller => 'work_orders', :action => 'wo_update_worker_select_from_area'
    match 'wo_update_worker_select_from_area/:id', :controller => 'work_orders', :action => 'wo_update_worker_select_from_area'
    match 'work_orders/:id/wo_update_worker_select_from_area/:id', :controller => 'work_orders', :action => 'wo_update_worker_select_from_area'

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
