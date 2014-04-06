Ag2Tech::Engine.routes.draw do
  scope "(:locale)", :locale => /en|es/ do
    # Get
    get "home/index"

    # Routes for jQuery POSTs
    match 'projects/update_company_textfield_from_office/:id', :controller => 'projects', :action => 'update_company_textfield_from_office'
    match 'projects/:id/update_company_textfield_from_office/:id', :controller => 'projects', :action => 'update_company_textfield_from_office'
    match 'work_orders/update_account_textfield_from_project/:id', :controller => 'work_orders', :action => 'update_account_textfield_from_project'
    match 'work_orders/:id/update_account_textfield_from_project/:id', :controller => 'work_orders', :action => 'update_account_textfield_from_project'

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
