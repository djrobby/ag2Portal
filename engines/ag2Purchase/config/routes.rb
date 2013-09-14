Ag2Purchase::Engine.routes.draw do
  scope "(:locale)", :locale => /en|es/ do
    # Get
    get "home/index"
    
    # Resources
    resources :suppliers
    resources :activities
    resources :payment_methods

    # Root
    root :to => 'home#index'
  end
end
