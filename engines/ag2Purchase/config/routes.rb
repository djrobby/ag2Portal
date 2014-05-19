Ag2Purchase::Engine.routes.draw do
  scope "(:locale)", :locale => /en|es/ do
    # Get
    get "home/index"
    
    # Patterns
    DECIMAL_PATTERN = /-?\d+(\.\d+)/
    
    # Routes for jQuery POSTs
    # Numbers with decimals (.) must be multiplied (by 1xxx and the same zeroes x positions) before passed as REST parameter! 
    match 'suppliers/update_province_textfield_from_town/:id', :controller => 'suppliers', :action => 'update_province_textfield_from_town'
    match 'suppliers/:id/update_province_textfield_from_town/:id', :controller => 'suppliers', :action => 'update_province_textfield_from_town'
    match 'suppliers/update_province_textfield_from_zipcode/:id', :controller => 'suppliers', :action => 'update_province_textfield_from_zipcode'
    match 'suppliers/:id/update_province_textfield_from_zipcode/:id', :controller => 'suppliers', :action => 'update_province_textfield_from_zipcode'
    match 'suppliers/update_country_textfield_from_region/:id', :controller => 'suppliers', :action => 'update_country_textfield_from_region'
    match 'suppliers/:id/update_country_textfield_from_region/:id', :controller => 'suppliers', :action => 'update_country_textfield_from_region'
    match 'suppliers/update_region_textfield_from_province/:id', :controller => 'suppliers', :action => 'update_region_textfield_from_province'
    match 'suppliers/:id/update_region_textfield_from_province/:id', :controller => 'suppliers', :action => 'update_region_textfield_from_province'
    match 'suppliers/validate_fiscal_id_textfield/:id', :controller => 'suppliers', :action => 'validate_fiscal_id_textfield'
    match 'suppliers/:id/validate_fiscal_id_textfield/:id', :controller => 'suppliers', :action => 'validate_fiscal_id_textfield'
    match 'suppliers/update_code_textfield/:id', :controller => 'suppliers', :action => 'update_code_textfield'
    match 'suppliers/:id/update_code_textfield/:id', :controller => 'suppliers', :action => 'update_code_textfield'
    match 'suppliers/su_format_amount/:num', :controller => 'suppliers', :action => 'su_format_amount'
    match 'su_format_amount/:num', :controller => 'suppliers', :action => 'su_format_amount'
    match 'suppliers/:id/su_format_amount/:num', :controller => 'suppliers', :action => 'su_format_amount'
    match 'suppliers/su_format_percentage/:num', :controller => 'suppliers', :action => 'su_format_percentage'
    match 'su_format_percentage/:num', :controller => 'suppliers', :action => 'su_format_percentage'
    match 'suppliers/:id/su_format_percentage/:num', :controller => 'suppliers', :action => 'su_format_percentage'
    #
    match 'purchase_orders/po_update_description_prices_from_product/:product/:qty', :controller => 'purchase_orders', :action => 'po_update_description_prices_from_product'
    match 'po_update_description_prices_from_product/:product/:qty', :controller => 'purchase_orders', :action => 'po_update_description_prices_from_product'
    match 'purchase_orders/:id/po_update_description_prices_from_product/:product/:qty', :controller => 'purchase_orders', :action => 'po_update_description_prices_from_product'
    match 'purchase_orders/po_update_amount_from_price_or_quantity/:price/:qty/:tax_type/:discount_p/:discount', :controller => 'purchase_orders', :action => 'po_update_amount_from_price_or_quantity'
    match 'po_update_amount_from_price_or_quantity/:price/:qty/:tax_type/:discount_p/:discount', :controller => 'purchase_orders', :action => 'po_update_amount_from_price_or_quantity'
    match 'purchase_orders/:id/po_update_amount_from_price_or_quantity/:price/:qty/:tax_type/:discount_p/:discount', :controller => 'purchase_orders', :action => 'po_update_amount_from_price_or_quantity'
    match 'purchase_orders/po_update_project_from_order/:order', :controller => 'purchase_orders', :action => 'po_update_project_from_order'
    match 'po_update_project_from_order/:price/:qty/:order', :controller => 'purchase_orders', :action => 'po_update_project_from_order'
    match 'purchase_orders/:id/po_update_project_from_order/:order', :controller => 'purchase_orders', :action => 'po_update_project_from_order'
    match 'purchase_orders/po_update_charge_account_from_project/:order', :controller => 'purchase_orders', :action => 'po_update_charge_account_from_project'
    match 'po_update_charge_account_from_project/:price/:qty/:order', :controller => 'purchase_orders', :action => 'po_update_charge_account_from_project'
    match 'purchase_orders/:id/po_update_charge_account_from_project/:order', :controller => 'purchase_orders', :action => 'po_update_charge_account_from_project'
    match 'purchase_orders/po_update_offer_select_from_supplier/:supplier', :controller => 'purchase_orders', :action => 'po_update_offer_select_from_supplier'
    match 'po_update_offer_select_from_supplier/:supplier', :controller => 'purchase_orders', :action => 'po_update_offer_select_from_supplier'
    match 'purchase_orders/:id/po_update_offer_select_from_supplier/:supplier', :controller => 'purchase_orders', :action => 'po_update_offer_select_from_supplier'
    match 'purchase_orders/po_format_number/:num', :controller => 'purchase_orders', :action => 'po_format_number'
    match 'po_format_number/:num', :controller => 'purchase_orders', :action => 'po_format_number'
    match 'purchase_orders/:id/po_format_number/:num', :controller => 'purchase_orders', :action => 'po_format_number'
    match 'purchase_orders/po_totals/:qty/:amount/:tax/:discount_p', :controller => 'purchase_orders', :action => 'po_totals'
    match 'po_totals/:qty/:amount/:tax/:discount_p', :controller => 'purchase_orders', :action => 'po_totals'
    match 'purchase_orders/:id/po_totals/:qty/:amount/:tax/:discount_p', :controller => 'purchase_orders', :action => 'po_totals'
    #
    match 'payment_methods/pm_format_numbers/:num', :controller => 'payment_methods', :action => 'pm_format_numbers'
    match 'pm_format_numbers/:num', :controller => 'payment_methods', :action => 'pm_format_numbers'
    match 'payment_methods/:id/pm_format_numbers/:num', :controller => 'payment_methods', :action => 'pm_format_numbers'

    # Resources
    resources :suppliers
    resources :activities
    resources :payment_methods
    resources :supplier_contacts
    resources :order_statuses
    resources :purchase_orders

    # Root
    root :to => 'home#index'
  end
end
