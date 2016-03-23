Ag2Products::Engine.routes.draw do
  scope "(:locale)", :locale => /en|es/ do
    # Get
    get "home/index"

    # Routes to Control&Tracking
    match 'ag2_products_track' => 'ag2_products_track#index', :as => :ag2_products_track
    #
    # Control&Tracking
    match 'pr_track_project_has_changed/:order', :controller => 'ag2_products_track', :action => 'pr_track_project_has_changed'
    match 'pr_track_family_has_changed/:order', :controller => 'ag2_products_track', :action => 'pr_track_family_has_changed'
    # Reports
    match 'inventory_report', :controller => 'ag2_products_track', :action => 'inventory_report'
    match 'order_report', :controller => 'ag2_products_track', :action => 'order_report'
    match 'receipt_report', :controller => 'ag2_products_track', :action => 'receipt_report'
    match 'delivery_report', :controller => 'ag2_products_track', :action => 'delivery_report'
    match 'stock_report', :controller => 'ag2_products_track', :action => 'stock_report'

    match 'inventory_counts_report', :controller => 'inventory_counts', :action => 'inventory_counts_report'
    match 'receipt_notes_report', :controller => 'receipt_notes', :action => 'receipt_notes_report'
    match 'delivery_notes_report', :controller => 'delivery_notes', :action => 'delivery_notes_report'
    match 'purchase_orders_report', :controller => 'purchase_orders', :action => 'purchase_orders_report'

    # Routes for jQuery POSTs
    # Numbers with decimals (.) must be multiplied (by 1xxx and the same zeroes x positions) before passed as REST parameter!
    # Stores
    match 'stores/st_update_company_textfield_from_office/:id', :controller => 'stores', :action => 'st_update_company_textfield_from_office'
    match 'st_update_company_textfield_from_office/:id', :controller => 'stores', :action => 'st_update_company_textfield_from_office'
    match 'stores/:id/st_update_company_textfield_from_office/:id', :controller => 'stores', :action => 'st_update_company_textfield_from_office'
    match 'stores/st_update_company_and_office_textfields_from_organization/:id', :controller => 'stores', :action => 'st_update_company_and_office_textfields_from_organization'
    match 'st_update_company_and_office_textfields_from_organization/:id', :controller => 'stores', :action => 'st_update_company_and_office_textfields_from_organization'
    match 'stores/:id/st_update_company_and_office_textfields_from_organization/:id', :controller => 'stores', :action => 'st_update_company_and_office_textfields_from_organization'
    match 'stores/st_update_province_textfield_from_town/:id', :controller => 'stores', :action => 'st_update_province_textfield_from_town'
    match 'st_update_province_textfield_from_town/:id', :controller => 'stores', :action => 'st_update_province_textfield_from_town'
    match 'stores/:id/st_update_province_textfield_from_town/:id', :controller => 'stores', :action => 'st_update_province_textfield_from_town'
    match 'stores/st_update_province_textfield_from_zipcode/:id', :controller => 'stores', :action => 'st_update_province_textfield_from_zipcode'
    match 'st_update_province_textfield_from_zipcode/:id', :controller => 'stores', :action => 'st_update_province_textfield_from_zipcode'
    match 'stores/:id/st_update_province_textfield_from_zipcode/:id', :controller => 'stores', :action => 'st_update_province_textfield_from_zipcode'
    #
    # Products
    match 'products/pr_update_code_textfield/:fam/:org', :controller => 'products', :action => 'pr_update_code_textfield'
    match 'pr_update_code_textfield/:fam/:org', :controller => 'products', :action => 'pr_update_code_textfield'
    match 'products/:id/pr_update_code_textfield/:fam/:org', :controller => 'products', :action => 'pr_update_code_textfield'
    match 'products/pr_format_amount/:num', :controller => 'products', :action => 'pr_format_amount'
    match 'pr_format_amount/:num', :controller => 'products', :action => 'pr_format_amount'
    match 'products/:id/pr_format_amount/:num', :controller => 'products', :action => 'pr_format_amount'
    match 'products/pr_markup/:markup/:sell/:reference', :controller => 'products', :action => 'pr_markup'
    match 'pr_markup/:markup/:sell/:reference', :controller => 'products', :action => 'pr_markup'
    match 'products/:id/pr_markup/:markup/:sell/:reference', :controller => 'products', :action => 'pr_markup'
    match 'products/pr_update_family_textfield_from_organization/:org', :controller => 'products', :action => 'pr_update_family_textfield_from_organization'
    match 'pr_update_family_textfield_from_organization/:org', :controller => 'products', :action => 'pr_update_family_textfield_from_organization'
    match 'products/:id/pr_update_family_textfield_from_organization/:org', :controller => 'products', :action => 'pr_update_family_textfield_from_organization'
    match 'products/pr_update_attachment', :controller => 'products', :action => 'pr_update_attachment'
    match 'pr_update_attachment', :controller => 'products', :action => 'pr_update_attachment'
    match 'products/:id/pr_update_attachment', :controller => 'products', :action => 'pr_update_attachment'
    #
    # Families
    match 'product_families/pf_format_numbers/:num', :controller => 'product_families', :action => 'pf_format_numbers'
    match 'pf_format_numbers/:num', :controller => 'product_families', :action => 'pf_format_numbers'
    match 'product_families/:id/pf_format_numbers/:num', :controller => 'product_families', :action => 'pf_format_numbers'
    #
    # Stocks
    match 'stocks/st_format_numbers/:num', :controller => 'stocks', :action => 'st_format_numbers'
    match 'st_format_numbers/:num', :controller => 'stocks', :action => 'st_format_numbers'
    match 'stocks/:id/st_format_numbers/:num', :controller => 'stocks', :action => 'st_format_numbers'
    #
    # Prices
    match 'purchase_prices/pp_format_numbers/:num', :controller => 'purchase_prices', :action => 'pp_format_numbers'
    match 'pp_format_numbers/:num', :controller => 'purchase_prices', :action => 'pp_format_numbers'
    match 'purchase_prices/:id/pp_format_numbers/:num', :controller => 'purchase_prices', :action => 'pp_format_numbers'
    match 'purchase_prices/pp_format_numbers_2/:num', :controller => 'purchase_prices', :action => 'pp_format_numbers_2'
    match 'pp_format_numbers_2/:num', :controller => 'purchase_prices', :action => 'pp_format_numbers_2'
    match 'purchase_prices/:id/pp_format_numbers_2/:num', :controller => 'purchase_prices', :action => 'pp_format_numbers_2'
    #
    # Product prices by company
    match 'product_company_prices/pp_format_numbers/:num', :controller => 'product_company_prices', :action => 'pp_format_numbers'
    match 'pp_format_numbers/:num', :controller => 'product_company_prices', :action => 'pp_format_numbers'
    match 'product_company_prices/:id/pp_format_numbers/:num', :controller => 'product_company_prices', :action => 'pp_format_numbers'
    match 'product_company_prices/pp_format_numbers_2/:num', :controller => 'product_company_prices', :action => 'pp_format_numbers_2'
    match 'pp_format_numbers_2/:num', :controller => 'product_company_prices', :action => 'pp_format_numbers_2'
    match 'product_company_prices/:id/pp_format_numbers_2/:num', :controller => 'product_company_prices', :action => 'pp_format_numbers_2'
    #
    # Delivery notes
    match 'delivery_notes/dn_totals/:qty/:amount/:costs/:tax/:discount_p', :controller => 'delivery_notes', :action => 'dn_totals'
    match 'dn_totals/:qty/:amount/:costs/:tax/:discount_p', :controller => 'delivery_notes', :action => 'dn_totals'
    match 'delivery_notes/:id/dn_totals/:qty/:amount/:costs/:tax/:discount_p', :controller => 'delivery_notes', :action => 'dn_totals'
    match 'delivery_notes/dn_update_description_prices_from_product_store/:product/:qty/:store/:tbl', :controller => 'delivery_notes', :action => 'dn_update_description_prices_from_product_store'
    match 'dn_update_description_prices_from_product_store/:product/:qty/:store/:tbl', :controller => 'delivery_notes', :action => 'dn_update_description_prices_from_product_store'
    match 'delivery_notes/:id/dn_update_description_prices_from_product_store/:product/:qty/:store/:tbl', :controller => 'delivery_notes', :action => 'dn_update_description_prices_from_product_store'
    match 'delivery_notes/dn_update_description_prices_from_product/:product/:qty', :controller => 'delivery_notes', :action => 'dn_update_description_prices_from_product'
    match 'dn_update_description_prices_from_product/:product/:qty', :controller => 'delivery_notes', :action => 'dn_update_description_prices_from_product'
    match 'delivery_notes/:id/dn_update_description_prices_from_product/:product/:qty', :controller => 'delivery_notes', :action => 'dn_update_description_prices_from_product'
    match 'delivery_notes/dn_update_amount_and_costs_from_price_or_quantity/:cost/:price/:qty/:tax_type/:discount_p/:discount/:product/:tbl', :controller => 'delivery_notes', :action => 'dn_update_amount_and_costs_from_price_or_quantity'
    match 'dn_update_amount_and_costs_from_price_or_quantity/:cost/:price/:qty/:tax_type/:discount_p/:discount/:product/:tbl', :controller => 'delivery_notes', :action => 'dn_update_amount_and_costs_from_price_or_quantity'
    match 'delivery_notes/:id/dn_update_amount_and_costs_from_price_or_quantity/:cost/:price/:qty/:tax_type/:discount_p/:discount/:product/:tbl', :controller => 'delivery_notes', :action => 'dn_update_amount_and_costs_from_price_or_quantity'
    match 'delivery_notes/dn_update_charge_account_from_order/:order', :controller => 'delivery_notes', :action => 'dn_update_charge_account_from_order'
    match 'dn_update_charge_account_from_order/:price/:qty/:order', :controller => 'delivery_notes', :action => 'dn_update_charge_account_from_order'
    match 'delivery_notes/:id/dn_update_charge_account_from_order/:order', :controller => 'delivery_notes', :action => 'dn_update_charge_account_from_order'
    match 'delivery_notes/dn_update_charge_account_from_project/:order', :controller => 'delivery_notes', :action => 'dn_update_charge_account_from_project'
    match 'dn_update_charge_account_from_project/:price/:qty/:order', :controller => 'delivery_notes', :action => 'dn_update_charge_account_from_project'
    match 'delivery_notes/:id/dn_update_charge_account_from_project/:order', :controller => 'delivery_notes', :action => 'dn_update_charge_account_from_project'
    match 'delivery_notes/dn_update_offer_select_from_client/:client', :controller => 'delivery_notes', :action => 'dn_update_offer_select_from_client'
    match 'dn_update_offer_select_from_client/:client', :controller => 'delivery_notes', :action => 'dn_update_offer_select_from_client'
    match 'delivery_notes/:id/dn_update_offer_select_from_client/:client', :controller => 'delivery_notes', :action => 'dn_update_offer_select_from_client'
    match 'delivery_notes/dn_format_number/:num', :controller => 'delivery_notes', :action => 'dn_format_number'
    match 'dn_format_number/:num', :controller => 'delivery_notes', :action => 'dn_format_number'
    match 'delivery_notes/:id/dn_format_number/:num', :controller => 'delivery_notes', :action => 'dn_format_number'
    match 'delivery_notes/dn_current_stock/:product/:store', :controller => 'delivery_notes', :action => 'dn_current_stock'
    match 'dn_current_stock/:product/:store', :controller => 'delivery_notes', :action => 'dn_current_stock'
    match 'delivery_notes/:id/dn_current_stock/:product/:store', :controller => 'delivery_notes', :action => 'dn_current_stock'
    match 'delivery_notes/dn_item_stock_check/:store/:product/:qty', :controller => 'delivery_notes', :action => 'dn_item_stock_check'
    match 'dn_item_stock_check/:store/:product/:qty', :controller => 'delivery_notes', :action => 'dn_item_stock_check'
    match 'delivery_notes/:id/dn_item_stock_check/:store/:product/:qty', :controller => 'delivery_notes', :action => 'dn_item_stock_check'
    match 'delivery_notes/dn_update_project_textfields_from_organization/:org', :controller => 'delivery_notes', :action => 'dn_update_project_textfields_from_organization'
    match 'dn_update_project_textfields_from_organization/:org', :controller => 'delivery_notes', :action => 'dn_update_project_textfields_from_organization'
    match 'delivery_notes/:id/dn_update_project_textfields_from_organization/:org', :controller => 'delivery_notes', :action => 'dn_update_project_textfields_from_organization'
    match 'delivery_notes/dn_generate_no/:project', :controller => 'delivery_notes', :action => 'dn_generate_no'
    match 'dn_generate_no/:project', :controller => 'delivery_notes', :action => 'dn_generate_no'
    match 'delivery_notes/:id/dn_generate_no/:project', :controller => 'delivery_notes', :action => 'dn_generate_no'
    #
    # Receipt notes
    match 'receipt_notes/rn_totals/:qty/:amount/:tax/:discount_p', :controller => 'receipt_notes', :action => 'rn_totals'
    match 'rn_totals/:qty/:amount/:tax/:discount_p', :controller => 'receipt_notes', :action => 'rn_totals'
    match 'receipt_notes/:id/rn_totals/:qty/:amount/:tax/:discount_p', :controller => 'receipt_notes', :action => 'rn_totals'
    match 'receipt_notes/rn_update_description_prices_from_product_store/:product/:qty/:store/:supplier/:tbl', :controller => 'receipt_notes', :action => 'rn_update_description_prices_from_product_store'
    match 'rn_update_description_prices_from_product_store/:product/:qty/:store/:supplier/:tbl', :controller => 'receipt_notes', :action => 'rn_update_description_prices_from_product_store'
    match 'receipt_notes/:id/rn_update_description_prices_from_product_store/:product/:qty/:store/:supplier/:tbl', :controller => 'receipt_notes', :action => 'rn_update_description_prices_from_product_store'
    match 'receipt_notes/rn_update_description_prices_from_product/:product/:qty/:supplier', :controller => 'receipt_notes', :action => 'rn_update_description_prices_from_product'
    match 'rn_update_description_prices_from_product/:product/:qty/:supplier', :controller => 'receipt_notes', :action => 'rn_update_description_prices_from_product'
    match 'receipt_notes/:id/rn_update_description_prices_from_product/:product/:qty/:supplier', :controller => 'receipt_notes', :action => 'rn_update_description_prices_from_product'
    match 'receipt_notes/rn_update_amount_from_price_or_quantity/:price/:qty/:tax_type/:discount_p/:discount/:product/:tbl', :controller => 'receipt_notes', :action => 'rn_update_amount_from_price_or_quantity'
    match 'rn_update_amount_from_price_or_quantity/:price/:qty/:tax_type/:discount_p/:discount/:product/:tbl', :controller => 'receipt_notes', :action => 'rn_update_amount_from_price_or_quantity'
    match 'receipt_notes/:id/rn_update_amount_from_price_or_quantity/:price/:qty/:tax_type/:discount_p/:discount/:product/:tbl', :controller => 'receipt_notes', :action => 'rn_update_amount_from_price_or_quantity'
    match 'receipt_notes/rn_update_charge_account_from_order/:order', :controller => 'receipt_notes', :action => 'rn_update_charge_account_from_order'
    match 'rn_update_charge_account_from_order/:price/:qty/:order', :controller => 'receipt_notes', :action => 'rn_update_charge_account_from_order'
    match 'receipt_notes/:id/rn_update_charge_account_from_order/:order', :controller => 'receipt_notes', :action => 'rn_update_charge_account_from_order'
    match 'receipt_notes/rn_update_charge_account_from_project/:order', :controller => 'receipt_notes', :action => 'rn_update_charge_account_from_project'
    match 'rn_update_charge_account_from_project/:order', :controller => 'receipt_notes', :action => 'rn_update_charge_account_from_project'
    match 'receipt_notes/:id/rn_update_charge_account_from_project/:order', :controller => 'receipt_notes', :action => 'rn_update_charge_account_from_project'
    match 'receipt_notes/rn_update_order_select_from_supplier/:supplier', :controller => 'receipt_notes', :action => 'rn_update_order_select_from_supplier'
    match 'rn_update_order_select_from_supplier/:supplier', :controller => 'receipt_notes', :action => 'rn_update_order_select_from_supplier'
    match 'receipt_notes/:id/rn_update_order_select_from_supplier/:supplier', :controller => 'receipt_notes', :action => 'rn_update_order_select_from_supplier'
    match 'receipt_notes/rn_format_number/:num', :controller => 'receipt_notes', :action => 'rn_format_number'
    match 'rn_format_number/:num', :controller => 'receipt_notes', :action => 'rn_format_number'
    match 'receipt_notes/:id/rn_format_number/:num', :controller => 'receipt_notes', :action => 'rn_format_number'
    match 'receipt_notes/rn_current_stock/:product/:store', :controller => 'receipt_notes', :action => 'rn_current_stock'
    match 'rn_current_stock/:product/:store', :controller => 'receipt_notes', :action => 'rn_current_stock'
    match 'receipt_notes/:id/rn_current_stock/:product/:store', :controller => 'receipt_notes', :action => 'rn_current_stock'
    match 'receipt_notes/rn_update_project_textfields_from_organization/:org', :controller => 'receipt_notes', :action => 'rn_update_project_textfields_from_organization'
    match 'rn_update_project_textfields_from_organization/:org', :controller => 'receipt_notes', :action => 'rn_update_project_textfields_from_organization'
    match 'receipt_notes/:id/rn_update_project_textfields_from_organization/:org', :controller => 'receipt_notes', :action => 'rn_update_project_textfields_from_organization'
    match 'receipt_notes/rn_update_selects_from_order/:o', :controller => 'receipt_notes', :action => 'rn_update_selects_from_order'
    match 'rn_update_selects_from_order/:o', :controller => 'receipt_notes', :action => 'rn_update_selects_from_order'
    match 'receipt_notes/:id/rn_update_selects_from_order/:o', :controller => 'receipt_notes', :action => 'rn_update_selects_from_order'
    match 'receipt_notes/rn_update_product_select_from_order_item/:i', :controller => 'receipt_notes', :action => 'rn_update_product_select_from_order_item'
    match 'rn_update_product_select_from_order_item/:i', :controller => 'receipt_notes', :action => 'rn_update_product_select_from_order_item'
    match 'receipt_notes/:id/rn_update_product_select_from_order_item/:i', :controller => 'receipt_notes', :action => 'rn_update_product_select_from_order_item'
    match 'receipt_notes/rn_item_balance_check/:i/:qty', :controller => 'receipt_notes', :action => 'rn_item_balance_check'
    match 'rn_item_balance_check/:i/:qty', :controller => 'receipt_notes', :action => 'rn_item_balance_check'
    match 'receipt_notes/:id/rn_item_balance_check/:i/:qty', :controller => 'receipt_notes', :action => 'rn_item_balance_check'
    match 'receipt_notes/rn_update_attachment', :controller => 'receipt_notes', :action => 'rn_update_attachment'
    match 'rn_update_attachment', :controller => 'receipt_notes', :action => 'rn_update_attachment'
    match 'receipt_notes/:id/rn_update_attachment', :controller => 'receipt_notes', :action => 'rn_update_attachment'
    match 'receipt_notes/rn_attachment_changed', :controller => 'receipt_notes', :action => 'rn_attachment_changed'
    match 'rn_attachment_changed', :controller => 'receipt_notes', :action => 'rn_attachment_changed'
    match 'receipt_notes/:id/rn_attachment_changed', :controller => 'receipt_notes', :action => 'rn_attachment_changed'
    match 'receipt_notes/rn_generate_note/:supplier/:request/:offer_no/:offer_date', :controller => 'receipt_notes', :action => 'rn_generate_note'
    match 'rn_generate_note/:supplier/:request/:offer_no/:offer_date', :controller => 'receipt_notes', :action => 'rn_generate_note'
    match 'receipt_notes/:id/rn_generate_note/:supplier/:request/:offer_no/:offer_date', :controller => 'receipt_notes', :action => 'rn_generate_note'
    match 'receipt_notes/rn_current_balance/:order', :controller => 'receipt_notes', :action => 'rn_current_balance'
    match 'rn_current_balance/:order', :controller => 'receipt_notes', :action => 'rn_current_balance'
    match 'receipt_notes/:id/rn_current_balance/:order', :controller => 'receipt_notes', :action => 'rn_current_balance'
    #
    # Purchase orders
    match 'purchase_orders/po_update_description_prices_from_product_store/:product/:qty/:store/:supplier/:tbl', :controller => 'purchase_orders', :action => 'po_update_description_prices_from_product_store'
    match 'po_update_description_prices_from_product_store/:product/:qty/:store/:supplier/:tbl', :controller => 'purchase_orders', :action => 'po_update_description_prices_from_product_store'
    match 'purchase_orders/:id/po_update_description_prices_from_product_store/:product/:qty/:store/:supplier/:tbl', :controller => 'purchase_orders', :action => 'po_update_description_prices_from_product_store'
    match 'purchase_orders/po_update_description_prices_from_product/:product/:qty/:supplier', :controller => 'purchase_orders', :action => 'po_update_description_prices_from_product'
    match 'po_update_description_prices_from_product/:product/:qty/:supplier', :controller => 'purchase_orders', :action => 'po_update_description_prices_from_product'
    match 'purchase_orders/:id/po_update_description_prices_from_product/:product/:qty/:supplier', :controller => 'purchase_orders', :action => 'po_update_description_prices_from_product'
    match 'purchase_orders/po_update_amount_from_price_or_quantity/:price/:qty/:tax_type/:discount_p/:discount/:product/:tbl', :controller => 'purchase_orders', :action => 'po_update_amount_from_price_or_quantity'
    match 'po_update_amount_from_price_or_quantity/:price/:qty/:tax_type/:discount_p/:discount/:product/:tbl', :controller => 'purchase_orders', :action => 'po_update_amount_from_price_or_quantity'
    match 'purchase_orders/:id/po_update_amount_from_price_or_quantity/:price/:qty/:tax_type/:discount_p/:discount/:product/:tbl', :controller => 'purchase_orders', :action => 'po_update_amount_from_price_or_quantity'
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
    match 'purchase_orders/po_check_stock_and_price/:product/:qty/:store/:check_stock/:supplier/:price/:discount', :controller => 'purchase_orders', :action => 'po_check_stock_and_price'
    match 'po_check_stock_and_price/:product/:qty/:store/:check_stock/:supplier/:price/:discount', :controller => 'purchase_orders', :action => 'po_check_stock_and_price'
    match 'purchase_orders/:id/po_check_stock_and_price/:product/:qty/:store/:check_stock/:supplier/:price/:discount', :controller => 'purchase_orders', :action => 'po_check_stock_and_price'
    match 'purchase_orders/po_product_stock/:product/:qty/:store', :controller => 'purchase_orders', :action => 'po_product_stock'
    match 'po_product_stock/:product/:qty/:store', :controller => 'purchase_orders', :action => 'po_product_stock'
    match 'purchase_orders/:id/po_product_stock/:product/:qty/:store', :controller => 'purchase_orders', :action => 'po_product_stock'
    match 'purchase_orders/po_product_price/:product/:supplier/:price/:discount', :controller => 'purchase_orders', :action => 'po_product_price'
    match 'po_product_price/:product/:supplier/:price/:discount', :controller => 'purchase_orders', :action => 'po_product_price'
    match 'purchase_orders/:id/po_product_price/:product/:supplier/:price/:discount', :controller => 'purchase_orders', :action => 'po_product_price'
    match 'purchase_orders/po_product_all_stocks/:product', :controller => 'purchase_orders', :action => 'po_product_all_stocks'
    match 'po_product_all_stocks/:product', :controller => 'purchase_orders', :action => 'po_product_all_stocks'
    match 'purchase_orders/:id/po_product_all_stocks/:product', :controller => 'purchase_orders', :action => 'po_product_all_stocks'
    match 'purchase_orders/po_approve_order/:order', :controller => 'purchase_orders', :action => 'po_approve_order'
    match 'po_approve_order/:order', :controller => 'purchase_orders', :action => 'po_approve_order'
    match 'purchase_orders/:id/po_approve_order/:order', :controller => 'purchase_orders', :action => 'po_approve_order'
    match 'purchase_orders/po_check_stock_before_approve/:order', :controller => 'purchase_orders', :action => 'po_check_stock_before_approve'
    match 'po_check_stock_before_approve/:order', :controller => 'purchase_orders', :action => 'po_check_stock_before_approve'
    match 'purchase_orders/:id/po_check_stock_before_approve/:order', :controller => 'purchase_orders', :action => 'po_check_stock_before_approve'
    match 'purchase_orders/po_update_selects_from_offer/:o', :controller => 'purchase_orders', :action => 'po_update_selects_from_offer'
    match 'po_update_selects_from_offer/:o', :controller => 'purchase_orders', :action => 'po_update_selects_from_offer'
    match 'purchase_orders/:id/po_update_selects_from_offer/:o', :controller => 'purchase_orders', :action => 'po_update_selects_from_offer'
    match 'purchase_orders/po_update_addresses_from_store/:store', :controller => 'purchase_orders', :action => 'po_update_addresses_from_store'
    match 'po_update_addresses_from_store/:store', :controller => 'purchase_orders', :action => 'po_update_addresses_from_store'
    match 'purchase_orders/:id/po_update_addresses_from_store/:store', :controller => 'purchase_orders', :action => 'po_update_addresses_from_store'
    match 'purchase_orders/send_purchase_order_form/:id', :controller => 'purchase_orders', :action => 'send_purchase_order_form'
    match 'send_purchase_order_form/:id', :controller => 'purchase_orders', :action => 'send_purchase_order_form'
    match 'purchase_orders/:id/send_purchase_order_form/:id', :controller => 'purchase_orders', :action => 'send_purchase_order_form'

    match 'purchase_orders/send_notification/:id/:user', :controller => 'purchase_orders', :action => 'send_notification'
    match 'send_notification/:id/:user', :controller => 'purchase_orders', :action => 'send_notification'
    match 'purchase_orders/:id/send_notification/:id/:user', :controller => 'purchase_orders', :action => 'send_notification'
    #
    # Inventory counts
    match 'inventory_counts/ic_totals/:qty/:tbl', :controller => 'inventory_counts', :action => 'ic_totals'
    match 'ic_totals/:qty/:tbl', :controller => 'inventory_counts', :action => 'ic_totals'
    match 'inventory_counts/:id/ic_totals/:qty/:tbl', :controller => 'inventory_counts', :action => 'ic_totals'
    match 'inventory_counts/ic_update_family_select_from_store/:store/:type', :controller => 'inventory_counts', :action => 'ic_update_family_select_from_store'
    match 'ic_update_family_select_from_store/:store/:type', :controller => 'inventory_counts', :action => 'ic_update_family_select_from_store'
    match 'inventory_counts/:id/ic_update_family_select_from_store/:store/:type', :controller => 'inventory_counts', :action => 'ic_update_family_select_from_store'
    match 'inventory_counts/ic_generate_count/:store/:family/:type', :controller => 'inventory_counts', :action => 'ic_generate_count'
    match 'ic_generate_count/:store/:family/:type', :controller => 'inventory_counts', :action => 'ic_generate_count'
    match 'inventory_counts/:id/ic_generate_count/:store/:family/:type', :controller => 'inventory_counts', :action => 'ic_generate_count'
    match 'inventory_counts/ic_generate_no/:store', :controller => 'inventory_counts', :action => 'ic_generate_no'
    match 'ic_generate_no/:store', :controller => 'inventory_counts', :action => 'ic_generate_no'
    match 'inventory_counts/:id/ic_generate_no/:store', :controller => 'inventory_counts', :action => 'ic_generate_no'
    match 'inventory_counts/ic_update_from_product_store/:product/:qty/:store/:tbl', :controller => 'inventory_counts', :action => 'ic_update_from_product_store'
    match 'ic_update_from_product_store/:product/:qty/:store/:tbl', :controller => 'inventory_counts', :action => 'ic_update_from_product_store'
    match 'inventory_counts/:id/ic_update_from_product_store/:product/:qty/:store/:tbl', :controller => 'inventory_counts', :action => 'ic_update_from_product_store'
    match 'inventory_counts/ic_update_from_organization/:org', :controller => 'inventory_counts', :action => 'ic_update_from_organization'
    match 'ic_update_from_organization/:org', :controller => 'inventory_counts', :action => 'ic_update_from_organization'
    match 'inventory_counts/:id/ic_update_from_organization/:org', :controller => 'inventory_counts', :action => 'ic_update_from_organization'
    match 'inventory_counts/ic_approve_count/:order', :controller => 'inventory_counts', :action => 'ic_approve_count'
    match 'ic_approve_count/:order', :controller => 'inventory_counts', :action => 'ic_approve_count'
    match 'inventory_counts/:id/ic_approve_count/:order', :controller => 'inventory_counts', :action => 'ic_approve_count'
    match 'inventory_counts/ic_products_from_organization', :controller => 'inventory_counts', :action => 'ic_products_from_organization'
    match 'ic_products_from_organization', :controller => 'inventory_counts', :action => 'ic_products_from_organization'
    match 'inventory_counts/:id/ic_products_from_organization', :controller => 'inventory_counts', :action => 'ic_products_from_organization'

    # Resources
    resources :product_families
    resources :product_types
    resources :measures
    resources :manufacturers
    resources :products do
      get 'receipts_deliveries', on: :collection
    end
    resources :stores do
      get 'receipts_deliveries', on: :collection
    end
    resources :stocks
    resources :purchase_prices
    resources :purchase_orders do
      get 'purchase_order_form', on: :collection
    end
    resources :delivery_notes do
      get 'delivery_note_form', on: :collection
      get 'delivery_note_form_client', on: :collection
    end
    resources :receipt_notes
    resources :inventory_count_types
    resources :inventory_counts do
      get 'inventory_count_form', on: :collection
    end
    resources :product_company_prices

    # Root
    root :to => 'home#index'
  end
end
