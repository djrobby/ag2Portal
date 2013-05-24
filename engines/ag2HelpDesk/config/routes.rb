Ag2HelpDesk::Engine.routes.draw do
  scope "(:locale)", :locale => /en|es/ do
    get "home/index"

    # Resources
    resources :ticket_categories
    resources :ticket_priorities
    resources :ticket_statuses

    # Root
    root :to => 'home#index'
  end
end
