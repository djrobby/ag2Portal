Ag2HelpDesk::Engine.routes.draw do
  scope "(:locale)", :locale => /en|es/ do
    # Get
    get "home/index"

    # Routes for jQuery POSTs
    match 'tickets/update_office_textfield_from_created_by/:id', :controller => 'tickets', :action => 'update_office_textfield_from_created_by'
    match 'tickets/:id/update_office_textfield_from_created_by/:id', :controller => 'tickets', :action => 'update_office_textfield_from_created_by'

    # Resources
    resources :ticket_categories
    resources :ticket_priorities
    resources :ticket_statuses
    resources :technicians
    resources :tickets

    # Root
    root :to => 'home#index'
  end
end
