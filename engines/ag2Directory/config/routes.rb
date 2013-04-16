Ag2Directory::Engine.routes.draw do
  get "home/index"

  # Routes to import
  match 'import' => 'import#index', :as => :import

  # Routes to search
  match '/corp_contacts/search', :controller => 'corp_contacts', :action => 'search'

  # Routes for jQuery POSTs
  match 'corp_contacts/update_company_textfield_from_office/:id', :controller => 'corp_contacts', :action => 'update_company_textfield_from_office'
  match 'corp_contacts/:id/update_company_textfield_from_office/:id', :controller => 'corp_contacts', :action => 'update_company_textfield_from_office'
  match 'corp_contacts/:id/update_company_textfield_from_office/:id', :controller => 'corp_contacts', :action => 'update_company_textfield_from_office'
  match 'data_import', :controller => 'import', :action => 'data_import'

  resources :corp_contacts

  root :to => 'home#index'
end
