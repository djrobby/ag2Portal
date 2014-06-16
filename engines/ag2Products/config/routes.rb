Ag2Products::Engine.routes.draw do
  scope "(:locale)", :locale => /en|es/ do
    # Get
    get "home/index"

    # Routes for jQuery POSTs
    match 'stores/update_company_textfield_from_office/:id', :controller => 'stores', :action => 'update_company_textfield_from_office'
    match 'stores/:id/update_company_textfield_from_office/:id', :controller => 'stores', :action => 'update_company_textfield_from_office'
    match 'products/update_code_textfield/:id', :controller => 'products', :action => 'update_code_textfield'
    match 'products/:id/update_code_textfield/:id', :controller => 'products', :action => 'update_code_textfield'
    match 'product_families/pf_format_numbers/:num', :controller => 'product_families', :action => 'pf_format_numbers'
    match 'pf_format_numbers/:num', :controller => 'product_families', :action => 'pf_format_numbers'
    match 'product_families/:id/pf_format_numbers/:num', :controller => 'product_families', :action => 'pf_format_numbers'
    match 'stocks/st_format_numbers/:num', :controller => 'stocks', :action => 'st_format_numbers'
    match 'st_format_numbers/:num', :controller => 'stocks', :action => 'st_format_numbers'
    match 'stocks/:id/st_format_numbers/:num', :controller => 'stocks', :action => 'st_format_numbers'
    match 'purchase_prices/pp_format_numbers/:num', :controller => 'purchase_prices', :action => 'pp_format_numbers'
    match 'pp_format_numbers/:num', :controller => 'purchase_prices', :action => 'pp_format_numbers'
    match 'purchase_prices/:id/pp_format_numbers/:num', :controller => 'purchase_prices', :action => 'pp_format_numbers'
    match 'products/pr_format_amount/:num', :controller => 'products', :action => 'pr_format_amount'
    match 'pr_format_amount/:num', :controller => 'products', :action => 'pr_format_amount'
    match 'products/:id/pr_format_amount/:num', :controller => 'products', :action => 'pr_format_amount'
    match 'products/pr_markup/:markup/:sell/:reference', :controller => 'products', :action => 'pr_markup'
    match 'pr_markup/:markup/:sell/:reference', :controller => 'products', :action => 'pr_markup'
    match 'products/:id/pr_markup/:markup/:sell/:reference', :controller => 'products', :action => 'pr_markup'

    # Resources
    resources :products
    resources :product_families
    resources :product_types
    resources :measures
    resources :manufacturers
    resources :stores
    resources :purchase_prices
    resources :stocks
    resources :delivery_notes
    resources :receipt_notes

    # Root
    root :to => 'home#index'
  end
end
