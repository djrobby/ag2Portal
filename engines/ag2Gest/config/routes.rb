Ag2Gest::Engine.routes.draw do
  scope "(:locale)", :locale => /en|es/ do
    # Get
    get "home/index"

    # Routes to import

    # Routes to search

    # Routes for jQuery POSTs

    # Resources
    resources :clients
    
    # Root
    root :to => 'home#index'
  end
end
