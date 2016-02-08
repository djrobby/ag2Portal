Ag2HelpDesk::Engine.routes.draw do
  scope "(:locale)", :locale => /en|es/ do
    # Get
    get "home/index"

    # Control&Tracking

    # Routes for jQuery POSTs
    #
    # Tickets
    match 'tickets/ti_update_office_textfield_from_created_by/:cb', :controller => 'tickets', :action => 'ti_update_office_textfield_from_created_by'
    match 'ti_update_office_textfield_from_created_by/:cb', :controller => 'tickets', :action => 'ti_update_office_textfield_from_created_by'
    match 'tickets/:id/ti_update_office_textfield_from_created_by/:cb', :controller => 'tickets', :action => 'ti_update_office_textfield_from_created_by'
    match 'tickets/ti_update_attachment', :controller => 'tickets', :action => 'ti_update_attachment'
    match 'ti_update_attachment', :controller => 'tickets', :action => 'ti_update_attachment'
    match 'tickets/:id/ti_update_attachment', :controller => 'tickets', :action => 'ti_update_attachment'
    match 'tickets/ti_update_office_textfield_from_organization/:org', :controller => 'tickets', :action => 'ti_update_office_textfield_from_organization'
    match 'ti_update_office_textfield_from_organization/:org', :controller => 'tickets', :action => 'ti_update_office_textfield_from_organization'
    match 'tickets/:id/ti_update_office_textfield_from_organization/:org', :controller => 'tickets', :action => 'ti_update_office_textfield_from_organization'
    # Reports
    match 'tickets_report', :controller => 'tickets', :action => 'tickets_report'

    # Resources
    resources :ticket_categories
    resources :ticket_priorities
    resources :ticket_statuses
    resources :technicians
    resources :tickets do
      post 'popup_new', on: :collection
      get 'my_tickets', on: :collection
    end

    # Root
    root :to => 'home#index'
  end
end
