Ag2Purchase::Engine.routes.draw do
  scope "(:locale)", :locale => /en|es/ do
    # Get
    get "home/index"
    
    # Resources
    resources :suppliers

    # Root
    root :to => 'home#index'
  end
end
