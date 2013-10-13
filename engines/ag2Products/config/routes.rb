Ag2Products::Engine.routes.draw do
  scope "(:locale)", :locale => /en|es/ do
    # Get
    get "home/index"

    # Routes for jQuery POSTs

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
