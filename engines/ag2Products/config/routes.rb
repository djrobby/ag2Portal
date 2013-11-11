Ag2Products::Engine.routes.draw do
  scope "(:locale)", :locale => /en|es/ do
    # Get
    get "home/index"

    # Routes for jQuery POSTs
    match 'stores/update_company_textfield_from_office/:id', :controller => 'stores', :action => 'update_company_textfield_from_office'
    match 'stores/:id/update_company_textfield_from_office/:id', :controller => 'stores', :action => 'update_company_textfield_from_office'
    match 'products/update_code_textfield/:id', :controller => 'products', :action => 'update_code_textfield'
    match 'products/:id/update_code_textfield/:id', :controller => 'products', :action => 'update_code_textfield'

    # Resources
    resources :products
    resources :product_families
    resources :product_types
    resources :measures
    resources :manufacturers
    resources :stores
    resources :purchase_prices
    resources :stocks

    # Root
    root :to => 'home#index'
  end
end
