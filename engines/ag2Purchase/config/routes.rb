Ag2Purchase::Engine.routes.draw do
  scope "(:locale)", :locale => /en|es/ do
    # Get
    get "home/index"
    
    # Patterns
    DECIMAL_PATTERN = /-?\d+(\.\d+)/
    
    # Routes for jQuery POSTs
    # Numbers with decimals (.) must be multiplied (by 1xxx and the same zeroes x positions) before passed as REST parameter!
    #
    # Suppliers 
    match 'suppliers/update_province_textfield_from_town/:id', :controller => 'suppliers', :action => 'update_province_textfield_from_town'
    match 'suppliers/:id/update_province_textfield_from_town/:id', :controller => 'suppliers', :action => 'update_province_textfield_from_town'
    match 'suppliers/update_province_textfield_from_zipcode/:id', :controller => 'suppliers', :action => 'update_province_textfield_from_zipcode'
    match 'suppliers/:id/update_province_textfield_from_zipcode/:id', :controller => 'suppliers', :action => 'update_province_textfield_from_zipcode'
    match 'suppliers/update_country_textfield_from_region/:id', :controller => 'suppliers', :action => 'update_country_textfield_from_region'
    match 'suppliers/:id/update_country_textfield_from_region/:id', :controller => 'suppliers', :action => 'update_country_textfield_from_region'
    match 'suppliers/update_region_textfield_from_province/:id', :controller => 'suppliers', :action => 'update_region_textfield_from_province'
    match 'suppliers/:id/update_region_textfield_from_province/:id', :controller => 'suppliers', :action => 'update_region_textfield_from_province'
    match 'suppliers/validate_fiscal_id_textfield/:id', :controller => 'suppliers', :action => 'validate_fiscal_id_textfield'
    match 'validate_fiscal_id_textfield/:id', :controller => 'suppliers', :action => 'validate_fiscal_id_textfield'
    match 'suppliers/:id/validate_fiscal_id_textfield/:id', :controller => 'suppliers', :action => 'validate_fiscal_id_textfield'
    match 'suppliers/su_generate_code/:activity/:org', :controller => 'suppliers', :action => 'su_generate_code'
    match 'su_generate_code/:activity/:org', :controller => 'suppliers', :action => 'su_generate_code'
    match 'suppliers/:id/su_generate_code/:activity/:org', :controller => 'suppliers', :action => 'su_generate_code'
    match 'suppliers/su_format_amount/:num', :controller => 'suppliers', :action => 'su_format_amount'
    match 'su_format_amount/:num', :controller => 'suppliers', :action => 'su_format_amount'
    match 'suppliers/:id/su_format_amount/:num', :controller => 'suppliers', :action => 'su_format_amount'
    match 'suppliers/su_format_percentage/:num', :controller => 'suppliers', :action => 'su_format_percentage'
    match 'su_format_percentage/:num', :controller => 'suppliers', :action => 'su_format_percentage'
    match 'suppliers/:id/su_format_percentage/:num', :controller => 'suppliers', :action => 'su_format_percentage'
    match 'suppliers/et_validate_fiscal_id_textfield/:id', :controller => 'suppliers', :action => 'et_validate_fiscal_id_textfield'
    match 'et_validate_fiscal_id_textfield/:id', :controller => 'suppliers', :action => 'et_validate_fiscal_id_textfield'
    match 'suppliers/:id/et_validate_fiscal_id_textfield/:id', :controller => 'suppliers', :action => 'et_validate_fiscal_id_textfield'
    #
    # Purchase orders 
    match 'purchase_orders/po_update_description_prices_from_product_store/:product/:qty/:store', :controller => 'purchase_orders', :action => 'po_update_description_prices_from_product_store'
    match 'po_update_description_prices_from_product_store/:product/:qty/:store', :controller => 'purchase_orders', :action => 'po_update_description_prices_from_product_store'
    match 'purchase_orders/:id/po_update_description_prices_from_product_store/:product/:qty/:store', :controller => 'purchase_orders', :action => 'po_update_description_prices_from_product_store'
    match 'purchase_orders/po_update_description_prices_from_product/:product/:qty', :controller => 'purchase_orders', :action => 'po_update_description_prices_from_product'
    match 'po_update_description_prices_from_product/:product/:qty', :controller => 'purchase_orders', :action => 'po_update_description_prices_from_product'
    match 'purchase_orders/:id/po_update_description_prices_from_product/:product/:qty', :controller => 'purchase_orders', :action => 'po_update_description_prices_from_product'
    match 'purchase_orders/po_update_amount_from_price_or_quantity/:price/:qty/:tax_type/:discount_p/:discount/:product', :controller => 'purchase_orders', :action => 'po_update_amount_from_price_or_quantity'
    match 'po_update_amount_from_price_or_quantity/:price/:qty/:tax_type/:discount_p/:discount/:product', :controller => 'purchase_orders', :action => 'po_update_amount_from_price_or_quantity'
    match 'purchase_orders/:id/po_update_amount_from_price_or_quantity/:price/:qty/:tax_type/:discount_p/:discount/:product', :controller => 'purchase_orders', :action => 'po_update_amount_from_price_or_quantity'
    match 'purchase_orders/po_update_charge_account_from_order/:order', :controller => 'purchase_orders', :action => 'po_update_charge_account_from_order'
    match 'po_update_charge_account_from_order/:price/:qty/:order', :controller => 'purchase_orders', :action => 'po_update_charge_account_from_order'
    match 'purchase_orders/:id/po_update_charge_account_from_order/:order', :controller => 'purchase_orders', :action => 'po_update_charge_account_from_order'
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
    match 'purchase_orders/po_current_stock/:product/:store', :controller => 'purchase_orders', :action => 'po_current_stock'
    match 'po_current_stock/:product/:store', :controller => 'purchase_orders', :action => 'po_current_stock'
    match 'purchase_orders/:id/po_current_stock/:product/:store', :controller => 'purchase_orders', :action => 'po_current_stock'
    match 'purchase_orders/po_update_project_textfields_from_organization/:org', :controller => 'purchase_orders', :action => 'po_update_project_textfields_from_organization'
    match 'po_update_project_textfields_from_organization/:org', :controller => 'purchase_orders', :action => 'po_update_project_textfields_from_organization'
    match 'purchase_orders/:id/po_update_project_textfields_from_organization/:org', :controller => 'purchase_orders', :action => 'po_update_project_textfields_from_organization'
    match 'purchase_orders/po_generate_no/:project', :controller => 'purchase_orders', :action => 'po_generate_no'
    match 'po_generate_no/:project', :controller => 'purchase_orders', :action => 'po_generate_no'
    match 'purchase_orders/:id/po_generate_no/:project', :controller => 'purchase_orders', :action => 'po_generate_no'
    match 'purchase_orders/po_product_stock/:product/:qty/:store', :controller => 'purchase_orders', :action => 'po_product_stock'
    match 'po_product_stock/:product/:qty/:store', :controller => 'purchase_orders', :action => 'po_product_stock'
    match 'purchase_orders/:id/po_product_stock/:product/:qty/:store', :controller => 'purchase_orders', :action => 'po_product_stock'
    match 'purchase_orders/po_product_all_stocks/:product', :controller => 'purchase_orders', :action => 'po_product_all_stocks'
    match 'po_product_all_stocks/:product', :controller => 'purchase_orders', :action => 'po_product_all_stocks'
    match 'purchase_orders/:id/po_product_all_stocks/:product', :controller => 'purchase_orders', :action => 'po_product_all_stocks'
    #
    # Purchase order Reports
    #match 'purchase_order_form', :controller => 'purchase_orders', :action => 'purchase_order_form'
    #
    # Payment methods
    match 'payment_methods/pm_format_numbers/:num', :controller => 'payment_methods', :action => 'pm_format_numbers'
    match 'pm_format_numbers/:num', :controller => 'payment_methods', :action => 'pm_format_numbers'
    match 'payment_methods/:id/pm_format_numbers/:num', :controller => 'payment_methods', :action => 'pm_format_numbers'
    #
    # Supplier invoices
    match 'supplier_invoices/si_update_description_prices_from_product_store/:product/:qty/:store', :controller => 'supplier_invoices', :action => 'si_update_description_prices_from_product_store'
    match 'si_update_description_prices_from_product_store/:product/:qty/:store', :controller => 'supplier_invoices', :action => 'si_update_description_prices_from_product_store'
    match 'supplier_invoices/:id/si_update_description_prices_from_product_store/:product/:qty/:store', :controller => 'supplier_invoices', :action => 'si_update_description_prices_from_product_store'
    match 'supplier_invoices/si_update_description_prices_from_product/:product/:qty', :controller => 'supplier_invoices', :action => 'si_update_description_prices_from_product'
    match 'si_update_description_prices_from_product/:product/:qty', :controller => 'supplier_invoices', :action => 'si_update_description_prices_from_product'
    match 'supplier_invoices/:id/si_update_description_prices_from_product/:product/:qty', :controller => 'supplier_invoices', :action => 'si_update_description_prices_from_product'
    match 'supplier_invoices/si_update_amount_from_price_or_quantity/:price/:qty/:tax_type/:discount_p/:discount/:product', :controller => 'supplier_invoices', :action => 'si_update_amount_from_price_or_quantity'
    match 'si_update_amount_from_price_or_quantity/:price/:qty/:tax_type/:discount_p/:discount/:product', :controller => 'supplier_invoices', :action => 'si_update_amount_from_price_or_quantity'
    match 'supplier_invoices/:id/si_update_amount_from_price_or_quantity/:price/:qty/:tax_type/:discount_p/:discount/:product', :controller => 'supplier_invoices', :action => 'si_update_amount_from_price_or_quantity'
    match 'supplier_invoices/si_update_charge_account_from_order/:order', :controller => 'supplier_invoices', :action => 'si_update_charge_account_from_order'
    match 'si_update_charge_account_from_order/:price/:qty/:order', :controller => 'supplier_invoices', :action => 'si_update_charge_account_from_order'
    match 'supplier_invoices/:id/si_update_charge_account_from_order/:order', :controller => 'supplier_invoices', :action => 'si_update_charge_account_from_order'
    match 'supplier_invoices/si_update_charge_account_from_project/:order', :controller => 'supplier_invoices', :action => 'si_update_charge_account_from_project'
    match 'si_update_charge_account_from_project/:price/:qty/:order', :controller => 'supplier_invoices', :action => 'si_update_charge_account_from_project'
    match 'supplier_invoices/:id/si_update_charge_account_from_project/:order', :controller => 'supplier_invoices', :action => 'si_update_charge_account_from_project'
    match 'supplier_invoices/si_update_receipt_select_from_supplier/:supplier', :controller => 'supplier_invoices', :action => 'si_update_receipt_select_from_supplier'
    match 'si_update_receipt_select_from_supplier/:supplier', :controller => 'supplier_invoices', :action => 'si_update_receipt_select_from_supplier'
    match 'supplier_invoices/:id/si_update_receipt_select_from_supplier/:supplier', :controller => 'supplier_invoices', :action => 'si_update_receipt_select_from_supplier'
    match 'supplier_invoices/si_format_number/:num', :controller => 'supplier_invoices', :action => 'si_format_number'
    match 'si_format_number/:num', :controller => 'supplier_invoices', :action => 'si_format_number'
    match 'supplier_invoices/:id/si_format_number/:num', :controller => 'supplier_invoices', :action => 'si_format_number'
    match 'supplier_invoices/si_item_totals/:qty/:amount/:tax/:discount_p', :controller => 'supplier_invoices', :action => 'si_item_totals'
    match 'si_item_totals/:qty/:amount/:tax/:discount_p', :controller => 'supplier_invoices', :action => 'si_item_totals'
    match 'supplier_invoices/:id/si_item_totals/:qty/:amount/:tax/:discount_p', :controller => 'supplier_invoices', :action => 'si_item_totals'
    match 'supplier_invoices/si_approval_totals/:qty/:amount/:tax/:discount_p', :controller => 'supplier_invoices', :action => 'si_approval_totals'
    match 'si_approval_totals/:qty/:amount/:tax/:discount_p', :controller => 'supplier_invoices', :action => 'si_approval_totals'
    match 'supplier_invoices/:id/si_approval_totals/:qty/:amount/:tax/:discount_p', :controller => 'supplier_invoices', :action => 'si_approval_totals'
    match 'supplier_invoices/si_current_stock/:product/:store', :controller => 'supplier_invoices', :action => 'si_current_stock'
    match 'si_current_stock/:product/:store', :controller => 'supplier_invoices', :action => 'si_current_stock'
    match 'supplier_invoices/:id/si_current_stock/:product/:store', :controller => 'supplier_invoices', :action => 'si_current_stock'
    match 'supplier_invoices/si_update_project_textfields_from_organization/:org', :controller => 'supplier_invoices', :action => 'si_update_project_textfields_from_organization'
    match 'si_update_project_textfields_from_organization/:org', :controller => 'supplier_invoices', :action => 'si_update_project_textfields_from_organization'
    match 'supplier_invoices/:id/si_update_project_textfields_from_organization/:org', :controller => 'supplier_invoices', :action => 'si_update_project_textfields_from_organization'
    match 'supplier_invoices/si_update_approved_amount/:amount/:invoice', :controller => 'supplier_invoices', :action => 'si_update_approved_amount'
    match 'si_update_approved_amount/:amount/:invoice', :controller => 'supplier_invoices', :action => 'si_update_approved_amount'
    match 'supplier_invoices/:id/si_update_approved_amount/:amount/:invoice', :controller => 'supplier_invoices', :action => 'si_update_approved_amount'
    match 'supplier_invoices/si_current_invoice_debt/:invoice', :controller => 'supplier_invoices', :action => 'si_current_invoice_debt'
    match 'si_current_invoice_debt/:invoice', :controller => 'supplier_invoices', :action => 'si_current_invoice_debt'
    match 'supplier_invoices/:id/si_current_invoice_debt/:invoice', :controller => 'supplier_invoices', :action => 'si_current_invoice_debt'
    #
    # Offer requests
    match 'offer_requests/or_totals/:qty/:amount/:tax/:discount_p', :controller => 'offer_requests', :action => 'or_totals'
    match 'or_totals/:qty/:amount/:tax/:discount_p', :controller => 'offer_requests', :action => 'or_totals'
    match 'offer_requests/:id/or_totals/:qty/:amount/:tax/:discount_p', :controller => 'offer_requests', :action => 'or_totals'
    match 'offer_requests/or_update_description_prices_from_product_store/:product/:qty/:store', :controller => 'offer_requests', :action => 'or_update_description_prices_from_product_store'
    match 'or_update_description_prices_from_product_store/:product/:qty/:store', :controller => 'offer_requests', :action => 'or_update_description_prices_from_product_store'
    match 'offer_requests/:id/or_update_description_prices_from_product_store/:product/:qty/:store', :controller => 'offer_requests', :action => 'or_update_description_prices_from_product_store'
    match 'offer_requests/or_update_description_prices_from_product/:product/:qty', :controller => 'offer_requests', :action => 'or_update_description_prices_from_product'
    match 'or_update_description_prices_from_product/:product/:qty', :controller => 'offer_requests', :action => 'or_update_description_prices_from_product'
    match 'offer_requests/:id/or_update_description_prices_from_product/:product/:qty', :controller => 'offer_requests', :action => 'or_update_description_prices_from_product'
    #match 'offer_requests/or_update_amount_from_price_or_quantity/:price/:qty/:tax_type/:discount_p/:discount/:product', :controller => 'offer_requests', :action => 'or_update_amount_from_price_or_quantity'
    #match 'or_update_amount_from_price_or_quantity/:price/:qty/:tax_type/:discount_p/:discount/:product', :controller => 'offer_requests', :action => 'or_update_amount_from_price_or_quantity'
    #match 'offer_requests/:id/or_update_amount_from_price_or_quantity/:price/:qty/:tax_type/:discount_p/:discount/:product', :controller => 'offer_requests', :action => 'or_update_amount_from_price_or_quantity'

    match 'offer_requests/or_update_amount_from_price_or_quantity/:price/:qty/:tax_type/:product', :controller => 'offer_requests', :action => 'or_update_amount_from_price_or_quantity'
    match 'or_update_amount_from_price_or_quantity/:price/:qty/:tax_type/:product', :controller => 'offer_requests', :action => 'or_update_amount_from_price_or_quantity'
    match 'offer_requests/:id/or_update_amount_from_price_or_quantity/:price/:qty/:tax_type/:product', :controller => 'offer_requests', :action => 'or_update_amount_from_price_or_quantity'

    match 'offer_requests/or_update_charge_account_from_order/:order', :controller => 'offer_requests', :action => 'or_update_charge_account_from_order'
    match 'or_update_charge_account_from_order/:price/:qty/:order', :controller => 'offer_requests', :action => 'or_update_charge_account_from_order'
    match 'offer_requests/:id/or_update_charge_account_from_order/:order', :controller => 'offer_requests', :action => 'or_update_charge_account_from_order'
    match 'offer_requests/or_update_charge_account_from_project/:order', :controller => 'offer_requests', :action => 'or_update_charge_account_from_project'
    match 'or_update_charge_account_from_project/:price/:qty/:order', :controller => 'offer_requests', :action => 'or_update_charge_account_from_project'
    match 'offer_requests/:id/or_update_charge_account_from_project/:order', :controller => 'offer_requests', :action => 'or_update_charge_account_from_project'
    match 'offer_requests/or_format_number/:num', :controller => 'offer_requests', :action => 'or_format_number'
    match 'or_format_number/:num', :controller => 'offer_requests', :action => 'or_format_number'
    match 'offer_requests/:id/or_format_number/:num', :controller => 'offer_requests', :action => 'or_format_number'
    match 'offer_requests/or_current_stock/:product/:store', :controller => 'offer_requests', :action => 'or_current_stock'
    match 'or_current_stock/:product/:store', :controller => 'offer_requests', :action => 'or_current_stock'
    match 'offer_requests/:id/or_current_stock/:product/:store', :controller => 'offer_requests', :action => 'or_current_stock'
    match 'offer_requests/or_update_project_textfields_from_organization/:org', :controller => 'offer_requests', :action => 'or_update_project_textfields_from_organization'
    match 'or_update_project_textfields_from_organization/:org', :controller => 'offer_requests', :action => 'or_update_project_textfields_from_organization'
    match 'offer_requests/:id/or_update_project_textfields_from_organization/:org', :controller => 'offer_requests', :action => 'or_update_project_textfields_from_organization'
    match 'offer_requests/or_generate_no/:project', :controller => 'offer_requests', :action => 'or_generate_no'
    match 'or_generate_no/:project', :controller => 'offer_requests', :action => 'or_generate_no'
    match 'offer_requests/:id/or_generate_no/:project', :controller => 'offer_requests', :action => 'or_generate_no'
    match 'offer_requests/or_approve_offer/:offer/:offer_request', :controller => 'offer_requests', :action => 'or_approve_offer'
    match 'or_approve_offer/:offer/:offer_request', :controller => 'offer_requests', :action => 'or_approve_offer'
    match 'offer_requests/:id/or_approve_offer/:offer/:offer_request', :controller => 'offer_requests', :action => 'or_approve_offer'
    match 'offer_requests/or_disapprove_offer/:offer/:offer_request', :controller => 'offer_requests', :action => 'or_disapprove_offer'
    match 'or_disapprove_offer/:offer/:offer_request', :controller => 'offer_requests', :action => 'or_disapprove_offer'
    match 'offer_requests/:id/or_disapprove_offer/:offer/:offer_request', :controller => 'offer_requests', :action => 'or_disapprove_offer'
    #
    # Offers
    match 'offers/of_totals/:qty/:amount/:tax/:discount_p', :controller => 'offers', :action => 'of_totals'
    match 'of_totals/:qty/:amount/:tax/:discount_p', :controller => 'offers', :action => 'of_totals'
    match 'offers/:id/of_totals/:qty/:amount/:tax/:discount_p', :controller => 'offers', :action => 'of_totals'
    match 'offers/of_update_description_prices_from_product_store/:product/:qty/:store', :controller => 'offers', :action => 'of_update_description_prices_from_product_store'
    match 'of_update_description_prices_from_product_store/:product/:qty/:store', :controller => 'offers', :action => 'of_update_description_prices_from_product_store'
    match 'offers/:id/of_update_description_prices_from_product_store/:product/:qty/:store', :controller => 'offers', :action => 'of_update_description_prices_from_product_store'
    match 'offers/of_update_description_prices_from_product/:product/:qty', :controller => 'offers', :action => 'of_update_description_prices_from_product'
    match 'of_update_description_prices_from_product/:product/:qty', :controller => 'offers', :action => 'of_update_description_prices_from_product'
    match 'offers/:id/of_update_description_prices_from_product/:product/:qty', :controller => 'offers', :action => 'of_update_description_prices_from_product'
    match 'offers/of_update_amount_from_price_or_quantity/:price/:qty/:tax_type/:discount_p/:discount/:product', :controller => 'offers', :action => 'of_update_amount_from_price_or_quantity'
    match 'of_update_amount_from_price_or_quantity/:price/:qty/:tax_type/:discount_p/:discount/:product', :controller => 'offers', :action => 'of_update_amount_from_price_or_quantity'
    match 'offers/:id/of_update_amount_from_price_or_quantity/:price/:qty/:tax_type/:discount_p/:discount/:product', :controller => 'offers', :action => 'of_update_amount_from_price_or_quantity'
    match 'offers/of_update_charge_account_from_order/:order', :controller => 'offers', :action => 'of_update_charge_account_from_order'
    match 'of_update_charge_account_from_order/:price/:qty/:order', :controller => 'offers', :action => 'of_update_charge_account_from_order'
    match 'offers/:id/of_update_charge_account_from_order/:order', :controller => 'offers', :action => 'of_update_charge_account_from_order'
    match 'offers/of_update_charge_account_from_project/:order', :controller => 'offers', :action => 'of_update_charge_account_from_project'
    match 'of_update_charge_account_from_project/:price/:qty/:order', :controller => 'offers', :action => 'of_update_charge_account_from_project'
    match 'offers/:id/of_update_charge_account_from_project/:order', :controller => 'offers', :action => 'of_update_charge_account_from_project'
    match 'offers/of_format_number/:num', :controller => 'offers', :action => 'of_format_number'
    match 'of_format_number/:num', :controller => 'offers', :action => 'of_format_number'
    match 'offers/:id/of_format_number/:num', :controller => 'offers', :action => 'of_format_number'
    match 'offers/of_format_number_4/:num', :controller => 'offers', :action => 'of_format_number'
    match 'of_format_number_4/:num', :controller => 'offers', :action => 'of_format_number'
    match 'offers/:id/of_format_number_4/:num', :controller => 'offers', :action => 'of_format_number'
    match 'offers/of_current_stock/:product/:store', :controller => 'offers', :action => 'of_current_stock'
    match 'of_current_stock/:product/:store', :controller => 'offers', :action => 'of_current_stock'
    match 'offers/:id/of_current_stock/:product/:store', :controller => 'offers', :action => 'of_current_stock'
    match 'offers/of_update_project_textfields_from_organization/:org', :controller => 'offers', :action => 'of_update_project_textfields_from_organization'
    match 'of_update_project_textfields_from_organization/:org', :controller => 'offers', :action => 'of_update_project_textfields_from_organization'
    match 'offers/:id/of_update_project_textfields_from_organization/:org', :controller => 'offers', :action => 'of_update_project_textfields_from_organization'
    match 'offers/of_update_items_table_from_request/:request', :controller => 'offers', :action => 'of_update_items_table_from_request'
    match 'of_update_items_table_from_request/:request', :controller => 'offers', :action => 'of_update_items_table_from_request'
    match 'offers/:id/of_update_items_table_from_request/:request', :controller => 'offers', :action => 'of_update_items_table_from_request'
    match 'offers/of_generate_order/:offer', :controller => 'offers', :action => 'of_generate_order'
    match 'of_generate_order/:offer', :controller => 'offers', :action => 'of_generate_order'
    match 'offers/:id/of_generate_order/:offer', :controller => 'offers', :action => 'of_generate_order'

    # Resources
    resources :suppliers
    resources :activities
    resources :payment_methods
    resources :supplier_contacts
    resources :order_statuses
    resources :purchase_orders do
      get 'purchase_order_form', on: :collection
    end
    resources :offer_requests do
      get 'offer_request_form', on: :collection
    end
    resources :offers
    resources :supplier_invoices
    resources :supplier_payments

    # Root
    root :to => 'home#index'
  end
end
