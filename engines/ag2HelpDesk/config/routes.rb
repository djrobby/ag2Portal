Ag2HelpDesk::Engine.routes.draw do
  scope "(:locale)", :locale => /en|es/ do
    # Get
    get "home/index"

    # Routes for jQuery POSTs
    match 'tickets/update_office_textfield_from_created_by/:id', :controller => 'tickets', :action => 'update_office_textfield_from_created_by'
    match 'tickets/:id/update_office_textfield_from_created_by/:id', :controller => 'tickets', :action => 'update_office_textfield_from_created_by'
    match 'tickets/ti_update_attachment', :controller => 'tickets', :action => 'ti_update_attachment'
    match 'ti_update_attachment', :controller => 'tickets', :action => 'ti_update_attachment'
    match 'tickets/:id/ti_update_attachment', :controller => 'tickets', :action => 'ti_update_attachment'

    # Resources
    resources :ticket_categories
    resources :ticket_priorities
    resources :ticket_statuses
    resources :technicians
    resources :tickets do
      post 'popup_new', on: :collection
    end

    # Root
    root :to => 'home#index'
  end
end
