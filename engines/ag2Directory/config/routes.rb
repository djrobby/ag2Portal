Ag2Directory::Engine.routes.draw do
  get "home/index"

  # Routes for jQuery POSTs
  match 'corp_contacts/update_company_textfield_from_office/:id', :controller => 'corp_contacts', :action => 'update_company_textfield_from_office'
  match 'corp_contacts/:id/update_company_textfield_from_office/:id', :controller => 'corp_contacts', :action => 'update_company_textfield_from_office'

  resources :corp_contacts

  root :to => 'home#index'
end
