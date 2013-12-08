Ag2Tech::Engine.routes.draw do
  scope "(:locale)", :locale => /en|es/ do
    # Get
    get "home/index"

    # Routes for jQuery POSTs

    # Resources
    
    # Root
    root :to => 'home#index'
  end
end
