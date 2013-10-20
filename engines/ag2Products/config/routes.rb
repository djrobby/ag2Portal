Ag2Products::Engine.routes.draw do
  scope "(:locale)", :locale => /en|es/ do
    # Get
    get "home/index"

    # Routes for jQuery POSTs
    match 'stores/update_company_textfield_from_office/:id', :controller => 'stores', :action => 'update_company_textfield_from_office'
    match 'stores/:id/update_company_textfield_from_office/:id', :controller => 'stores', :action => 'update_company_textfield_from_office'

    # Resources
    resources :products
    resources :product_families
    resources :product_types
    resources :measures
    resources :manufacturers
    resources :stores

    # Root
    root :to => 'home#index'
  end
end
