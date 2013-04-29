Ag2Directory::Engine.routes.draw do
  scope "(:locale)", :locale => /en|es/ do
    # Get
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
    match 'shared_contacts/update_province_textfield_from_town/:id', :controller => 'shared_contacts', :action => 'update_province_textfield_from_town'
    match 'shared_contacts/:id/update_province_textfield_from_town/:id', :controller => 'shared_contacts', :action => 'update_province_textfield_from_town'
    match 'shared_contacts/update_province_textfield_from_zipcode/:id', :controller => 'shared_contacts', :action => 'update_province_textfield_from_zipcode'
    match 'shared_contacts/:id/update_province_textfield_from_zipcode/:id', :controller => 'shared_contacts', :action => 'update_province_textfield_from_zipcode'

    # Resources
    resources :corp_contacts
    resources :shared_contacts
    resources :shared_contact_types
    
    # Root
    root :to => 'home#index'
  end
end
