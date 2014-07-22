# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140722181224) do

  create_table "activities", :force => true do |t|
    t.string   "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "created_by"
    t.string   "updated_by"
  end

  add_index "activities", ["description"], :name => "index_activities_on_description"

  create_table "apps", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "site_id"
    t.string   "path"
    t.string   "pict_file"
    t.string   "icon_file"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "apps", ["name"], :name => "index_apps_on_name"
  add_index "apps", ["site_id"], :name => "index_apps_on_site_id"

  create_table "areas", :force => true do |t|
    t.string   "name"
    t.integer  "department_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.integer  "worker_id"
  end

  add_index "areas", ["department_id"], :name => "index_areas_on_department_id"
  add_index "areas", ["name"], :name => "index_areas_on_name"
  add_index "areas", ["worker_id"], :name => "index_areas_on_worker_id"

  create_table "attachments", :force => true do |t|
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
  end

  create_table "charge_accounts", :force => true do |t|
    t.string   "name"
    t.date     "opened_at"
    t.date     "closed_at"
    t.integer  "project_id"
    t.string   "ledger_account"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.string   "account_code"
  end

  add_index "charge_accounts", ["account_code"], :name => "index_charge_accounts_on_account_code"
  add_index "charge_accounts", ["ledger_account"], :name => "index_charge_accounts_on_ledger_account"
  add_index "charge_accounts", ["name"], :name => "index_charge_accounts_on_name"
  add_index "charge_accounts", ["project_id"], :name => "index_charge_accounts_on_project_id"

  create_table "clients", :force => true do |t|
    t.integer  "entity_id"
    t.string   "client_code"
    t.string   "name"
    t.string   "fiscal_id"
    t.integer  "street_type_id"
    t.string   "street_name"
    t.string   "street_number"
    t.string   "building"
    t.integer  "floor"
    t.string   "floor_office"
    t.integer  "zipcode_id"
    t.integer  "town_id"
    t.integer  "province_id"
    t.integer  "region_id"
    t.integer  "country_id"
    t.string   "phone"
    t.string   "fax"
    t.string   "cellular"
    t.string   "email"
    t.boolean  "active"
    t.string   "remarks"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "clients", ["client_code"], :name => "index_clients_on_client_code"
  add_index "clients", ["country_id"], :name => "index_clients_on_country_id"
  add_index "clients", ["entity_id"], :name => "index_clients_on_entity_id"
  add_index "clients", ["fiscal_id"], :name => "index_clients_on_fiscal_id"
  add_index "clients", ["name"], :name => "index_clients_on_name"
  add_index "clients", ["province_id"], :name => "index_clients_on_province_id"
  add_index "clients", ["region_id"], :name => "index_clients_on_region_id"
  add_index "clients", ["street_type_id"], :name => "index_clients_on_street_type_id"
  add_index "clients", ["town_id"], :name => "index_clients_on_town_id"
  add_index "clients", ["zipcode_id"], :name => "index_clients_on_zipcode_id"

  create_table "collective_agreements", :force => true do |t|
    t.string   "name"
    t.string   "ca_code"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.string   "nomina_id"
    t.integer  "hours",      :limit => 2, :default => 0
  end

  add_index "collective_agreements", ["ca_code"], :name => "index_collective_agreements_on_ca_code"
  add_index "collective_agreements", ["nomina_id"], :name => "index_collective_agreements_on_nomina_id"

  create_table "companies", :force => true do |t|
    t.string   "name"
    t.string   "fiscal_id"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.integer  "street_type_id"
    t.string   "street_name"
    t.string   "street_number"
    t.string   "building"
    t.integer  "floor"
    t.string   "floor_office"
    t.integer  "zipcode_id"
    t.integer  "town_id"
    t.integer  "province_id"
    t.string   "phone"
    t.string   "fax"
    t.string   "cellular"
    t.string   "email"
    t.string   "invoice_code"
    t.string   "invoice_header"
    t.string   "invoice_footer"
    t.string   "invoice_left_margin"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.integer  "organization_id"
    t.string   "hd_email"
  end

  add_index "companies", ["invoice_code"], :name => "index_companies_on_invoice_code"
  add_index "companies", ["organization_id", "fiscal_id"], :name => "index_companies_on_organization_id_and_fiscal_id", :unique => true
  add_index "companies", ["province_id"], :name => "index_companies_on_province_id"
  add_index "companies", ["street_type_id"], :name => "index_companies_on_street_type_id"
  add_index "companies", ["town_id"], :name => "index_companies_on_town_id"
  add_index "companies", ["zipcode_id"], :name => "index_companies_on_zipcode_id"

  create_table "contract_types", :force => true do |t|
    t.string   "name"
    t.string   "ct_code"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.string   "nomina_id"
  end

  add_index "contract_types", ["ct_code"], :name => "index_contract_types_on_ct_code"
  add_index "contract_types", ["nomina_id"], :name => "index_contract_types_on_nomina_id"

  create_table "corp_contacts", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "company_id"
    t.integer  "office_id"
    t.integer  "department_id"
    t.string   "position"
    t.string   "email"
    t.string   "corp_phone"
    t.string   "corp_extension"
    t.string   "corp_cellular_long"
    t.string   "corp_cellular_short"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.integer  "worker_id"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.integer  "worker_count",        :limit => 2
  end

  add_index "corp_contacts", ["company_id"], :name => "index_corp_contacts_on_company_id"
  add_index "corp_contacts", ["corp_cellular_long"], :name => "index_corp_contacts_on_corp_cellular_long"
  add_index "corp_contacts", ["corp_cellular_short"], :name => "index_corp_contacts_on_corp_cellular_short"
  add_index "corp_contacts", ["corp_extension"], :name => "index_corp_contacts_on_corp_extension"
  add_index "corp_contacts", ["corp_phone"], :name => "index_corp_contacts_on_corp_phone"
  add_index "corp_contacts", ["department_id"], :name => "index_corp_contacts_on_department_id"
  add_index "corp_contacts", ["email"], :name => "index_corp_contacts_on_email"
  add_index "corp_contacts", ["first_name"], :name => "index_corp_contacts_on_first_name"
  add_index "corp_contacts", ["last_name"], :name => "index_corp_contacts_on_last_name"
  add_index "corp_contacts", ["office_id"], :name => "index_corp_contacts_on_office_id"
  add_index "corp_contacts", ["worker_id"], :name => "index_corp_contacts_on_worker_id"

  create_table "countries", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.string   "code"
  end

  add_index "countries", ["code"], :name => "index_countries_on_code"

  create_table "data_import_configs", :force => true do |t|
    t.string   "name"
    t.string   "source"
    t.string   "target"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "data_import_configs", ["name"], :name => "index_data_import_configs_on_name"

  create_table "degree_types", :force => true do |t|
    t.string   "name"
    t.string   "dt_code"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.string   "nomina_id"
  end

  add_index "degree_types", ["dt_code"], :name => "index_degree_types_on_dt_code"
  add_index "degree_types", ["nomina_id"], :name => "index_degree_types_on_nomina_id"

  create_table "delivery_note_items", :force => true do |t|
    t.integer  "delivery_note_id"
    t.integer  "sale_offer_id"
    t.integer  "sale_offer_item_id"
    t.integer  "product_id"
    t.string   "description"
    t.decimal  "quantity",           :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.decimal  "cost",               :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.decimal  "price",              :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.decimal  "discount_pct",       :precision => 6,  :scale => 2, :default => 0.0, :null => false
    t.decimal  "discount",           :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.integer  "tax_type_id"
    t.integer  "store_id"
    t.integer  "work_order_id"
    t.integer  "charge_account_id"
    t.datetime "created_at",                                                         :null => false
    t.datetime "updated_at",                                                         :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.integer  "project_id"
  end

  add_index "delivery_note_items", ["charge_account_id"], :name => "index_delivery_note_items_on_charge_account_id"
  add_index "delivery_note_items", ["delivery_note_id"], :name => "index_delivery_note_items_on_delivery_note_id"
  add_index "delivery_note_items", ["description"], :name => "index_delivery_note_items_on_description"
  add_index "delivery_note_items", ["product_id"], :name => "index_delivery_note_items_on_product_id"
  add_index "delivery_note_items", ["project_id"], :name => "index_delivery_note_items_on_project_id"
  add_index "delivery_note_items", ["sale_offer_id"], :name => "index_delivery_note_items_on_sale_offer_id"
  add_index "delivery_note_items", ["sale_offer_item_id"], :name => "index_delivery_note_items_on_sale_offer_item_id"
  add_index "delivery_note_items", ["store_id"], :name => "index_delivery_note_items_on_store_id"
  add_index "delivery_note_items", ["tax_type_id"], :name => "index_delivery_note_items_on_tax_type_id"
  add_index "delivery_note_items", ["work_order_id"], :name => "index_delivery_note_items_on_work_order_id"

  create_table "delivery_notes", :force => true do |t|
    t.string   "delivery_no"
    t.integer  "client_id"
    t.integer  "payment_method_id"
    t.date     "delivery_date"
    t.string   "remarks"
    t.decimal  "discount_pct",      :precision => 6,  :scale => 2, :default => 0.0, :null => false
    t.decimal  "discount",          :precision => 13, :scale => 4, :default => 0.0, :null => false
    t.integer  "project_id"
    t.integer  "store_id"
    t.integer  "work_order_id"
    t.integer  "charge_account_id"
    t.datetime "created_at",                                                        :null => false
    t.datetime "updated_at",                                                        :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.integer  "sale_offer_id"
  end

  add_index "delivery_notes", ["charge_account_id"], :name => "index_delivery_notes_on_charge_account_id"
  add_index "delivery_notes", ["client_id"], :name => "index_delivery_notes_on_client_id"
  add_index "delivery_notes", ["delivery_date"], :name => "index_delivery_notes_on_delivery_date"
  add_index "delivery_notes", ["delivery_no"], :name => "index_delivery_notes_on_delivery_no"
  add_index "delivery_notes", ["payment_method_id"], :name => "index_delivery_notes_on_payment_method_id"
  add_index "delivery_notes", ["project_id"], :name => "index_delivery_notes_on_project_id"
  add_index "delivery_notes", ["sale_offer_id"], :name => "index_delivery_notes_on_sale_offer_id"
  add_index "delivery_notes", ["store_id"], :name => "index_delivery_notes_on_store_id"
  add_index "delivery_notes", ["work_order_id"], :name => "index_delivery_notes_on_work_order_id"

  create_table "departments", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.string   "code"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.integer  "organization_id"
    t.integer  "company_id"
    t.integer  "worker_id"
  end

  add_index "departments", ["code"], :name => "index_departments_on_code"
  add_index "departments", ["company_id"], :name => "index_departments_on_company_id"
  add_index "departments", ["organization_id"], :name => "index_departments_on_organization_id"
  add_index "departments", ["worker_id"], :name => "index_departments_on_worker_id"

  create_table "entities", :force => true do |t|
    t.string   "fiscal_id"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "company"
    t.integer  "entity_type_id"
    t.integer  "street_type_id"
    t.string   "street_name"
    t.string   "street_number"
    t.string   "building"
    t.integer  "floor"
    t.string   "floor_office"
    t.integer  "zipcode_id"
    t.integer  "town_id"
    t.integer  "province_id"
    t.integer  "region_id"
    t.integer  "country_id"
    t.string   "phone"
    t.string   "extension"
    t.string   "fax"
    t.string   "cellular"
    t.string   "email"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.string   "created_by"
    t.string   "updated_by"
    t.integer  "organization_id"
  end

  add_index "entities", ["cellular"], :name => "index_entities_on_cellular"
  add_index "entities", ["company"], :name => "index_entities_on_company"
  add_index "entities", ["country_id"], :name => "index_entities_on_country_id"
  add_index "entities", ["email"], :name => "index_entities_on_email"
  add_index "entities", ["entity_type_id"], :name => "index_entities_on_entity_type_id"
  add_index "entities", ["first_name"], :name => "index_entities_on_first_name"
  add_index "entities", ["last_name"], :name => "index_entities_on_last_name"
  add_index "entities", ["organization_id", "fiscal_id"], :name => "index_entities_on_organization_id_and_fiscal_id", :unique => true
  add_index "entities", ["phone"], :name => "index_entities_on_phone"
  add_index "entities", ["province_id"], :name => "index_entities_on_province_id"
  add_index "entities", ["region_id"], :name => "index_entities_on_region_id"
  add_index "entities", ["street_type_id"], :name => "index_entities_on_street_type_id"
  add_index "entities", ["town_id"], :name => "index_entities_on_town_id"
  add_index "entities", ["zipcode_id"], :name => "index_entities_on_zipcode_id"

  create_table "entity_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "created_by"
    t.string   "updated_by"
  end

  create_table "fiscal_descriptions", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "fiscal_descriptions", ["code"], :name => "index_fiscal_descriptions_on_code", :unique => true

  create_table "guides", :force => true do |t|
    t.integer  "site_id"
    t.integer  "app_id"
    t.string   "name"
    t.string   "description"
    t.text     "body",        :limit => 16777215
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.integer  "sort_order"
  end

  add_index "guides", ["app_id"], :name => "index_guides_on_app_id"
  add_index "guides", ["name"], :name => "index_guides_on_name", :unique => true
  add_index "guides", ["site_id"], :name => "index_guides_on_site_id"
  add_index "guides", ["sort_order"], :name => "index_guides_on_sort_order"

  create_table "insurances", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "insurances", ["name"], :name => "index_insurances_on_name"

  create_table "manufacturers", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "created_by"
    t.string   "updated_by"
  end

  add_index "manufacturers", ["name"], :name => "index_manufacturers_on_name"

  create_table "measures", :force => true do |t|
    t.string   "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "created_by"
    t.string   "updated_by"
  end

  add_index "measures", ["description"], :name => "index_measures_on_description"

  create_table "offer_items", :force => true do |t|
    t.integer  "offer_id"
    t.integer  "product_id"
    t.string   "code"
    t.string   "description"
    t.decimal  "quantity",          :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.decimal  "price",             :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.decimal  "discount_pct",      :precision => 6,  :scale => 2, :default => 0.0, :null => false
    t.decimal  "discount",          :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.integer  "tax_type_id"
    t.date     "delivery_date"
    t.datetime "created_at",                                                        :null => false
    t.datetime "updated_at",                                                        :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.integer  "project_id"
    t.integer  "store_id"
    t.integer  "work_order_id"
    t.integer  "charge_account_id"
  end

  add_index "offer_items", ["charge_account_id"], :name => "index_offer_items_on_charge_account_id"
  add_index "offer_items", ["code"], :name => "index_offer_items_on_code"
  add_index "offer_items", ["description"], :name => "index_offer_items_on_description"
  add_index "offer_items", ["offer_id"], :name => "index_offer_items_on_offer_id"
  add_index "offer_items", ["product_id"], :name => "index_offer_items_on_product_id"
  add_index "offer_items", ["project_id"], :name => "index_offer_items_on_project_id"
  add_index "offer_items", ["store_id"], :name => "index_offer_items_on_store_id"
  add_index "offer_items", ["tax_type_id"], :name => "index_offer_items_on_tax_type_id"
  add_index "offer_items", ["work_order_id"], :name => "index_offer_items_on_work_order_id"

  create_table "offer_request_items", :force => true do |t|
    t.integer  "offer_request_id"
    t.integer  "product_id"
    t.string   "description"
    t.decimal  "quantity",          :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.decimal  "price",             :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.integer  "tax_type_id"
    t.datetime "created_at",                                                        :null => false
    t.datetime "updated_at",                                                        :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.integer  "project_id"
    t.integer  "store_id"
    t.integer  "work_order_id"
    t.integer  "charge_account_id"
  end

  add_index "offer_request_items", ["charge_account_id"], :name => "index_offer_request_items_on_charge_account_id"
  add_index "offer_request_items", ["description"], :name => "index_offer_request_items_on_description"
  add_index "offer_request_items", ["offer_request_id"], :name => "index_offer_request_items_on_offer_request_id"
  add_index "offer_request_items", ["product_id"], :name => "index_offer_request_items_on_product_id"
  add_index "offer_request_items", ["project_id"], :name => "index_offer_request_items_on_project_id"
  add_index "offer_request_items", ["store_id"], :name => "index_offer_request_items_on_store_id"
  add_index "offer_request_items", ["tax_type_id"], :name => "index_offer_request_items_on_tax_type_id"
  add_index "offer_request_items", ["work_order_id"], :name => "index_offer_request_items_on_work_order_id"

  create_table "offer_request_suppliers", :force => true do |t|
    t.integer  "offer_request_id"
    t.integer  "supplier_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "offer_request_suppliers", ["offer_request_id"], :name => "index_offer_request_suppliers_on_offer_request_id"
  add_index "offer_request_suppliers", ["supplier_id"], :name => "index_offer_request_suppliers_on_supplier_id"

  create_table "offer_requests", :force => true do |t|
    t.string   "request_no"
    t.date     "request_date"
    t.date     "deadline_date"
    t.integer  "payment_method_id"
    t.integer  "project_id"
    t.integer  "approved_offer_id"
    t.datetime "approval_date"
    t.integer  "approver_id"
    t.datetime "created_at",                                                        :null => false
    t.datetime "updated_at",                                                        :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.string   "remarks"
    t.decimal  "discount_pct",      :precision => 6,  :scale => 2, :default => 0.0, :null => false
    t.decimal  "discount",          :precision => 13, :scale => 4, :default => 0.0, :null => false
    t.integer  "store_id"
    t.integer  "work_order_id"
    t.integer  "charge_account_id"
  end

  add_index "offer_requests", ["approved_offer_id"], :name => "index_offer_requests_on_approved_offer_id"
  add_index "offer_requests", ["approver_id"], :name => "index_offer_requests_on_approver_id"
  add_index "offer_requests", ["charge_account_id"], :name => "index_offer_requests_on_charge_account_id"
  add_index "offer_requests", ["payment_method_id"], :name => "index_offer_requests_on_payment_method_id"
  add_index "offer_requests", ["project_id"], :name => "index_offer_requests_on_project_id"
  add_index "offer_requests", ["request_date"], :name => "index_offer_requests_on_request_date"
  add_index "offer_requests", ["request_no"], :name => "index_offer_requests_on_request_no"
  add_index "offer_requests", ["store_id"], :name => "index_offer_requests_on_store_id"
  add_index "offer_requests", ["work_order_id"], :name => "index_offer_requests_on_work_order_id"

  create_table "offers", :force => true do |t|
    t.integer  "offer_request_id"
    t.integer  "supplier_id"
    t.integer  "payment_method_id"
    t.string   "offer_no"
    t.date     "offer_date"
    t.string   "remarks"
    t.datetime "created_at",                                                        :null => false
    t.datetime "updated_at",                                                        :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.decimal  "discount_pct",      :precision => 6,  :scale => 2, :default => 0.0, :null => false
    t.decimal  "discount",          :precision => 13, :scale => 4, :default => 0.0, :null => false
    t.integer  "project_id"
    t.integer  "store_id"
    t.integer  "work_order_id"
    t.integer  "charge_account_id"
  end

  add_index "offers", ["charge_account_id"], :name => "index_offers_on_charge_account_id"
  add_index "offers", ["offer_date"], :name => "index_offers_on_offer_date"
  add_index "offers", ["offer_no"], :name => "index_offers_on_offer_no"
  add_index "offers", ["offer_request_id"], :name => "index_offers_on_offer_request_id"
  add_index "offers", ["payment_method_id"], :name => "index_offers_on_payment_method_id"
  add_index "offers", ["project_id"], :name => "index_offers_on_project_id"
  add_index "offers", ["store_id"], :name => "index_offers_on_store_id"
  add_index "offers", ["supplier_id"], :name => "index_offers_on_supplier_id"
  add_index "offers", ["work_order_id"], :name => "index_offers_on_work_order_id"

  create_table "offices", :force => true do |t|
    t.string   "name"
    t.integer  "company_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.string   "office_code"
    t.integer  "street_type_id"
    t.string   "street_name"
    t.string   "street_number"
    t.string   "building"
    t.integer  "floor"
    t.string   "floor_office"
    t.integer  "zipcode_id"
    t.integer  "town_id"
    t.integer  "province_id"
    t.string   "phone"
    t.string   "fax"
    t.string   "cellular"
    t.string   "email"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.string   "nomina_id"
  end

  add_index "offices", ["company_id"], :name => "index_offices_on_company_id"
  add_index "offices", ["nomina_id"], :name => "index_offices_on_nomina_id"
  add_index "offices", ["office_code"], :name => "index_offices_on_office_code"
  add_index "offices", ["province_id"], :name => "index_offices_on_province_id"
  add_index "offices", ["street_type_id"], :name => "index_offices_on_street_type_id"
  add_index "offices", ["town_id"], :name => "index_offices_on_town_id"
  add_index "offices", ["zipcode_id"], :name => "index_offices_on_zipcode_id"

  create_table "order_statuses", :force => true do |t|
    t.string   "name"
    t.boolean  "approval"
    t.boolean  "notification"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "order_statuses", ["name"], :name => "index_order_statuses_on_name"

  create_table "organizations", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.string   "hd_email"
  end

  add_index "organizations", ["name"], :name => "index_organizations_on_name"

  create_table "payment_methods", :force => true do |t|
    t.string   "description"
    t.integer  "expiration_days",                                              :default => 0,   :null => false
    t.decimal  "default_interest",              :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.datetime "created_at",                                                                    :null => false
    t.datetime "updated_at",                                                                    :null => false
    t.string   "created_by"
    t.string   "updated_by"
    t.integer  "flow",             :limit => 2
  end

  add_index "payment_methods", ["description"], :name => "index_payment_methods_on_description"
  add_index "payment_methods", ["flow"], :name => "index_payment_methods_on_flow"

  create_table "product_families", :force => true do |t|
    t.string   "name"
    t.string   "family_code"
    t.integer  "max_orders_count",                                :default => 0
    t.decimal  "max_orders_sum",   :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.datetime "created_at",                                                       :null => false
    t.datetime "updated_at",                                                       :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "product_families", ["family_code"], :name => "index_product_families_on_family_code"
  add_index "product_families", ["name"], :name => "index_product_families_on_name"

  create_table "product_types", :force => true do |t|
    t.string   "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  create_table "products", :force => true do |t|
    t.string   "product_code"
    t.string   "main_description"
    t.string   "aux_description"
    t.integer  "product_type_id"
    t.integer  "product_family_id"
    t.integer  "measure_id"
    t.integer  "tax_type_id"
    t.integer  "manufacturer_id"
    t.string   "manufacturer_p_code"
    t.decimal  "reference_price",                  :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.decimal  "last_price",                       :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.decimal  "average_price",                    :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.decimal  "sell_price",                       :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.decimal  "markup",                           :precision => 6,  :scale => 2, :default => 0.0, :null => false
    t.integer  "warranty_time",       :limit => 2,                                :default => 0,   :null => false
    t.integer  "life_time",           :limit => 2,                                :default => 0,   :null => false
    t.boolean  "active"
    t.string   "aux_code"
    t.string   "remarks"
    t.datetime "created_at",                                                                       :null => false
    t.datetime "updated_at",                                                                       :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.decimal  "prev_last_price",                  :precision => 12, :scale => 4, :default => 0.0, :null => false
  end

  add_index "products", ["active"], :name => "index_products_on_active"
  add_index "products", ["aux_description"], :name => "index_products_on_aux_description"
  add_index "products", ["main_description"], :name => "index_products_on_main_description"
  add_index "products", ["manufacturer_id"], :name => "index_products_on_manufacturer_id"
  add_index "products", ["measure_id"], :name => "index_products_on_measure_id"
  add_index "products", ["product_code"], :name => "index_products_on_product_code"
  add_index "products", ["product_family_id"], :name => "index_products_on_product_family_id"
  add_index "products", ["product_type_id"], :name => "index_products_on_product_type_id"
  add_index "products", ["tax_type_id"], :name => "index_products_on_tax_type_id"

  create_table "professional_groups", :force => true do |t|
    t.string   "name"
    t.string   "pg_code"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.string   "nomina_id"
  end

  add_index "professional_groups", ["nomina_id"], :name => "index_professional_groups_on_nomina_id"
  add_index "professional_groups", ["pg_code"], :name => "index_professional_groups_on_pg_code"

  create_table "projects", :force => true do |t|
    t.string   "name"
    t.date     "opened_at"
    t.date     "closed_at"
    t.integer  "office_id"
    t.integer  "company_id"
    t.string   "ledger_account"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.string   "project_code"
    t.integer  "organization_id"
  end

  add_index "projects", ["company_id"], :name => "index_projects_on_company_id"
  add_index "projects", ["ledger_account"], :name => "index_projects_on_ledger_account"
  add_index "projects", ["name"], :name => "index_projects_on_name"
  add_index "projects", ["office_id"], :name => "index_projects_on_office_id"
  add_index "projects", ["organization_id", "project_code"], :name => "index_projects_on_organization_id_and_project_code", :unique => true

  create_table "provinces", :force => true do |t|
    t.string   "name"
    t.string   "ine_cpro"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "region_id"
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "provinces", ["ine_cpro"], :name => "index_provinces_on_ine_cpro"
  add_index "provinces", ["region_id"], :name => "index_provinces_on_region_id"

  create_table "purchase_order_items", :force => true do |t|
    t.integer  "purchase_order_id"
    t.integer  "product_id"
    t.string   "code"
    t.string   "description"
    t.decimal  "quantity",          :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.decimal  "price",             :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.decimal  "discount_pct",      :precision => 6,  :scale => 2, :default => 0.0, :null => false
    t.decimal  "discount",          :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.integer  "tax_type_id"
    t.date     "delivery_date"
    t.datetime "created_at",                                                        :null => false
    t.datetime "updated_at",                                                        :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.integer  "project_id"
    t.integer  "store_id"
    t.integer  "work_order_id"
    t.integer  "charge_account_id"
  end

  add_index "purchase_order_items", ["charge_account_id"], :name => "index_purchase_order_items_on_charge_account_id"
  add_index "purchase_order_items", ["code"], :name => "index_purchase_order_items_on_code"
  add_index "purchase_order_items", ["delivery_date"], :name => "index_purchase_order_items_on_delivery_date"
  add_index "purchase_order_items", ["description"], :name => "index_purchase_order_items_on_description"
  add_index "purchase_order_items", ["product_id"], :name => "index_purchase_order_items_on_product_id"
  add_index "purchase_order_items", ["project_id"], :name => "index_purchase_order_items_on_project_id"
  add_index "purchase_order_items", ["purchase_order_id"], :name => "index_purchase_order_items_on_purchase_order_id"
  add_index "purchase_order_items", ["store_id"], :name => "index_purchase_order_items_on_store_id"
  add_index "purchase_order_items", ["tax_type_id"], :name => "index_purchase_order_items_on_tax_type_id"
  add_index "purchase_order_items", ["work_order_id"], :name => "index_purchase_order_items_on_work_order_id"

  create_table "purchase_orders", :force => true do |t|
    t.string   "order_no"
    t.integer  "supplier_id"
    t.integer  "payment_method_id"
    t.integer  "order_status_id"
    t.date     "order_date"
    t.string   "remarks"
    t.decimal  "discount_pct",      :precision => 6,  :scale => 2, :default => 0.0, :null => false
    t.decimal  "discount",          :precision => 13, :scale => 4, :default => 0.0, :null => false
    t.string   "supplier_offer_no"
    t.datetime "created_at",                                                        :null => false
    t.datetime "updated_at",                                                        :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.integer  "project_id"
    t.integer  "store_id"
    t.integer  "work_order_id"
    t.integer  "charge_account_id"
    t.decimal  "retention_pct",     :precision => 6,  :scale => 2, :default => 0.0, :null => false
    t.integer  "retention_time"
    t.integer  "offer_id"
  end

  add_index "purchase_orders", ["charge_account_id"], :name => "index_purchase_orders_on_charge_account_id"
  add_index "purchase_orders", ["offer_id"], :name => "index_purchase_orders_on_offer_id"
  add_index "purchase_orders", ["order_date"], :name => "index_purchase_orders_on_order_date"
  add_index "purchase_orders", ["order_no"], :name => "index_purchase_orders_on_order_no"
  add_index "purchase_orders", ["order_status_id"], :name => "index_purchase_orders_on_order_status_id"
  add_index "purchase_orders", ["payment_method_id"], :name => "index_purchase_orders_on_payment_method_id"
  add_index "purchase_orders", ["project_id"], :name => "index_purchase_orders_on_project_id"
  add_index "purchase_orders", ["store_id"], :name => "index_purchase_orders_on_store_id"
  add_index "purchase_orders", ["supplier_id"], :name => "index_purchase_orders_on_supplier_id"
  add_index "purchase_orders", ["work_order_id"], :name => "index_purchase_orders_on_work_order_id"

  create_table "purchase_prices", :force => true do |t|
    t.integer  "product_id"
    t.integer  "supplier_id"
    t.string   "code"
    t.decimal  "price",       :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.integer  "measure_id"
    t.decimal  "factor",      :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.boolean  "favorite"
    t.datetime "created_at",                                                  :null => false
    t.datetime "updated_at",                                                  :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.string   "prev_code"
    t.decimal  "prev_price",  :precision => 12, :scale => 4, :default => 0.0, :null => false
  end

  add_index "purchase_prices", ["code"], :name => "index_purchase_prices_on_code"
  add_index "purchase_prices", ["measure_id"], :name => "index_purchase_prices_on_measure_id"
  add_index "purchase_prices", ["product_id"], :name => "index_purchase_prices_on_product_id"
  add_index "purchase_prices", ["supplier_id"], :name => "index_purchase_prices_on_supplier_id"

  create_table "receipt_note_items", :force => true do |t|
    t.integer  "receipt_note_id"
    t.integer  "purchase_order_item_id"
    t.integer  "product_id"
    t.string   "description"
    t.decimal  "quantity",               :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.decimal  "price",                  :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.decimal  "discount_pct",           :precision => 6,  :scale => 2, :default => 0.0, :null => false
    t.decimal  "discount",               :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.integer  "tax_type_id"
    t.integer  "store_id"
    t.integer  "work_order_id"
    t.integer  "charge_account_id"
    t.datetime "created_at",                                                             :null => false
    t.datetime "updated_at",                                                             :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.string   "code"
    t.integer  "purchase_order_id"
    t.integer  "project_id"
  end

  add_index "receipt_note_items", ["charge_account_id"], :name => "index_receipt_note_items_on_charge_account_id"
  add_index "receipt_note_items", ["code"], :name => "index_receipt_note_items_on_code"
  add_index "receipt_note_items", ["description"], :name => "index_receipt_note_items_on_description"
  add_index "receipt_note_items", ["product_id"], :name => "index_receipt_note_items_on_product_id"
  add_index "receipt_note_items", ["project_id"], :name => "index_receipt_note_items_on_project_id"
  add_index "receipt_note_items", ["purchase_order_id"], :name => "index_receipt_note_items_on_purchase_order_id"
  add_index "receipt_note_items", ["purchase_order_item_id"], :name => "index_receipt_note_items_on_purchase_order_item_id"
  add_index "receipt_note_items", ["receipt_note_id"], :name => "index_receipt_note_items_on_receipt_note_id"
  add_index "receipt_note_items", ["store_id"], :name => "index_receipt_note_items_on_store_id"
  add_index "receipt_note_items", ["tax_type_id"], :name => "index_receipt_note_items_on_tax_type_id"
  add_index "receipt_note_items", ["work_order_id"], :name => "index_receipt_note_items_on_work_order_id"

  create_table "receipt_notes", :force => true do |t|
    t.string   "receipt_no"
    t.integer  "supplier_id"
    t.integer  "payment_method_id"
    t.date     "receipt_date"
    t.string   "remarks"
    t.decimal  "discount_pct",      :precision => 6,  :scale => 2, :default => 0.0, :null => false
    t.decimal  "discount",          :precision => 13, :scale => 4, :default => 0.0, :null => false
    t.integer  "project_id"
    t.integer  "store_id"
    t.integer  "work_order_id"
    t.integer  "charge_account_id"
    t.decimal  "retention_pct",     :precision => 6,  :scale => 2, :default => 0.0, :null => false
    t.integer  "retention_time"
    t.datetime "created_at",                                                        :null => false
    t.datetime "updated_at",                                                        :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.integer  "purchase_order_id"
  end

  add_index "receipt_notes", ["charge_account_id"], :name => "index_receipt_notes_on_charge_account_id"
  add_index "receipt_notes", ["payment_method_id"], :name => "index_receipt_notes_on_payment_method_id"
  add_index "receipt_notes", ["project_id"], :name => "index_receipt_notes_on_project_id"
  add_index "receipt_notes", ["purchase_order_id"], :name => "index_receipt_notes_on_purchase_order_id"
  add_index "receipt_notes", ["receipt_date"], :name => "index_receipt_notes_on_receipt_date"
  add_index "receipt_notes", ["receipt_no"], :name => "index_receipt_notes_on_receipt_no"
  add_index "receipt_notes", ["store_id"], :name => "index_receipt_notes_on_store_id"
  add_index "receipt_notes", ["supplier_id"], :name => "index_receipt_notes_on_supplier_id"
  add_index "receipt_notes", ["work_order_id"], :name => "index_receipt_notes_on_work_order_id"

  create_table "regions", :force => true do |t|
    t.string   "name"
    t.integer  "country_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "roles", ["name", "resource_type", "resource_id"], :name => "index_roles_on_name_and_resource_type_and_resource_id"
  add_index "roles", ["name"], :name => "index_roles_on_name"

  create_table "salary_concepts", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.string   "nomina_id"
  end

  add_index "salary_concepts", ["name"], :name => "index_salary_concepts_on_name"
  add_index "salary_concepts", ["nomina_id"], :name => "index_salary_concepts_on_nomina_id"

  create_table "sexes", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "sexes", ["name"], :name => "index_sexes_on_name"

  create_table "shared_contact_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  create_table "shared_contacts", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "company"
    t.string   "fiscal_id"
    t.string   "position"
    t.integer  "street_type_id"
    t.string   "street_name"
    t.string   "street_number"
    t.string   "building"
    t.integer  "floor"
    t.string   "floor_office"
    t.integer  "zipcode_id"
    t.integer  "town_id"
    t.integer  "province_id"
    t.integer  "country_id"
    t.string   "phone"
    t.string   "extension"
    t.string   "fax"
    t.string   "cellular"
    t.string   "email"
    t.integer  "shared_contact_type_id"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
    t.string   "remarks"
    t.integer  "region_id"
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "shared_contacts", ["cellular"], :name => "index_shared_contacts_on_cellular"
  add_index "shared_contacts", ["company"], :name => "index_shared_contacts_on_company"
  add_index "shared_contacts", ["country_id"], :name => "index_shared_contacts_on_country_id"
  add_index "shared_contacts", ["email"], :name => "index_shared_contacts_on_email"
  add_index "shared_contacts", ["first_name"], :name => "index_shared_contacts_on_first_name"
  add_index "shared_contacts", ["fiscal_id"], :name => "index_shared_contacts_on_fiscal_id"
  add_index "shared_contacts", ["last_name"], :name => "index_shared_contacts_on_last_name"
  add_index "shared_contacts", ["phone"], :name => "index_shared_contacts_on_phone"
  add_index "shared_contacts", ["province_id"], :name => "index_shared_contacts_on_province_id"
  add_index "shared_contacts", ["region_id"], :name => "index_shared_contacts_on_region_id"
  add_index "shared_contacts", ["shared_contact_type_id"], :name => "index_shared_contacts_on_shared_contact_type_id"
  add_index "shared_contacts", ["street_type_id"], :name => "index_shared_contacts_on_street_type_id"
  add_index "shared_contacts", ["town_id"], :name => "index_shared_contacts_on_town_id"
  add_index "shared_contacts", ["zipcode_id"], :name => "index_shared_contacts_on_zipcode_id"

  create_table "sites", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.string   "path"
    t.string   "pict_file"
    t.string   "icon_file"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "sites", ["name"], :name => "index_sites_on_name"

  create_table "stocks", :force => true do |t|
    t.integer  "product_id"
    t.integer  "store_id"
    t.decimal  "initial",    :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.decimal  "current",    :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.decimal  "minimum",    :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.string   "location"
    t.datetime "created_at",                                                 :null => false
    t.datetime "updated_at",                                                 :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.decimal  "maximum",    :precision => 12, :scale => 4, :default => 0.0, :null => false
  end

  add_index "stocks", ["product_id"], :name => "index_stocks_on_product_id"
  add_index "stocks", ["store_id"], :name => "index_stocks_on_store_id"

  create_table "stores", :force => true do |t|
    t.string   "name"
    t.integer  "company_id"
    t.integer  "office_id"
    t.string   "location"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.string   "created_by"
    t.string   "updated_by"
    t.integer  "organization_id"
    t.integer  "supplier_id"
  end

  add_index "stores", ["company_id"], :name => "index_stores_on_company_id"
  add_index "stores", ["name"], :name => "index_stores_on_name"
  add_index "stores", ["office_id"], :name => "index_stores_on_office_id"
  add_index "stores", ["organization_id"], :name => "index_stores_on_organization_id"
  add_index "stores", ["supplier_id"], :name => "index_stores_on_supplier_id"

  create_table "street_types", :force => true do |t|
    t.string   "street_type_code"
    t.string   "street_type_description"
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "street_types", ["street_type_code"], :name => "index_street_types_on_street_type_code"

  create_table "subguides", :force => true do |t|
    t.integer  "guide_id"
    t.string   "name"
    t.string   "description"
    t.text     "body",        :limit => 16777215
    t.integer  "sort_order"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "subguides", ["guide_id"], :name => "index_subguides_on_guide_id"
  add_index "subguides", ["name"], :name => "index_subguides_on_name", :unique => true
  add_index "subguides", ["sort_order"], :name => "index_subguides_on_sort_order"

  create_table "supplier_contacts", :force => true do |t|
    t.integer  "supplier_id"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "fiscal_id"
    t.string   "position"
    t.string   "department"
    t.string   "phone"
    t.string   "extension"
    t.string   "cellular"
    t.string   "email"
    t.string   "remarks"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "created_by"
    t.string   "updated_by"
  end

  add_index "supplier_contacts", ["cellular"], :name => "index_supplier_contacts_on_cellular"
  add_index "supplier_contacts", ["email"], :name => "index_supplier_contacts_on_email"
  add_index "supplier_contacts", ["first_name"], :name => "index_supplier_contacts_on_first_name"
  add_index "supplier_contacts", ["fiscal_id"], :name => "index_supplier_contacts_on_fiscal_id"
  add_index "supplier_contacts", ["last_name"], :name => "index_supplier_contacts_on_last_name"
  add_index "supplier_contacts", ["phone"], :name => "index_supplier_contacts_on_phone"
  add_index "supplier_contacts", ["supplier_id"], :name => "index_supplier_contacts_on_supplier_id"

  create_table "supplier_invoice_approvals", :force => true do |t|
    t.integer  "supplier_invoice_id"
    t.datetime "approval_date"
    t.decimal  "approved_amount",     :precision => 13, :scale => 4, :default => 0.0, :null => false
    t.integer  "approver_id"
    t.string   "remarks"
    t.datetime "created_at",                                                          :null => false
    t.datetime "updated_at",                                                          :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "supplier_invoice_approvals", ["approval_date"], :name => "index_supplier_invoice_approvals_on_approval_date"
  add_index "supplier_invoice_approvals", ["approver_id"], :name => "index_supplier_invoice_approvals_on_approver_id"
  add_index "supplier_invoice_approvals", ["supplier_invoice_id"], :name => "index_supplier_invoice_approvals_on_supplier_invoice_id"

  create_table "supplier_invoice_items", :force => true do |t|
    t.integer  "supplier_invoice_id"
    t.integer  "receipt_note_id"
    t.integer  "receipt_note_item_id"
    t.integer  "product_id"
    t.string   "code"
    t.string   "description"
    t.decimal  "quantity",             :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.decimal  "price",                :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.decimal  "discount_pct",         :precision => 6,  :scale => 2, :default => 0.0, :null => false
    t.decimal  "discount",             :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.integer  "tax_type_id"
    t.integer  "work_order_id"
    t.integer  "charge_account_id"
    t.datetime "created_at",                                                           :null => false
    t.datetime "updated_at",                                                           :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.integer  "project_id"
  end

  add_index "supplier_invoice_items", ["charge_account_id"], :name => "index_supplier_invoice_items_on_charge_account_id"
  add_index "supplier_invoice_items", ["code"], :name => "index_supplier_invoice_items_on_code"
  add_index "supplier_invoice_items", ["description"], :name => "index_supplier_invoice_items_on_description"
  add_index "supplier_invoice_items", ["product_id"], :name => "index_supplier_invoice_items_on_product_id"
  add_index "supplier_invoice_items", ["project_id"], :name => "index_supplier_invoice_items_on_project_id"
  add_index "supplier_invoice_items", ["receipt_note_id"], :name => "index_supplier_invoice_items_on_receipt_note_id"
  add_index "supplier_invoice_items", ["receipt_note_item_id"], :name => "index_supplier_invoice_items_on_receipt_note_item_id"
  add_index "supplier_invoice_items", ["supplier_invoice_id"], :name => "index_supplier_invoice_items_on_supplier_invoice_id"
  add_index "supplier_invoice_items", ["tax_type_id"], :name => "index_supplier_invoice_items_on_tax_type_id"
  add_index "supplier_invoice_items", ["work_order_id"], :name => "index_supplier_invoice_items_on_work_order_id"

  create_table "supplier_invoices", :force => true do |t|
    t.string   "invoice_no"
    t.integer  "supplier_id"
    t.integer  "payment_method_id"
    t.date     "invoice_date"
    t.string   "remarks"
    t.decimal  "discount_pct",      :precision => 6,  :scale => 2, :default => 0.0, :null => false
    t.decimal  "discount",          :precision => 13, :scale => 4, :default => 0.0, :null => false
    t.integer  "project_id"
    t.integer  "work_order_id"
    t.integer  "charge_account_id"
    t.datetime "created_at",                                                        :null => false
    t.datetime "updated_at",                                                        :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.date     "posted_at"
  end

  add_index "supplier_invoices", ["charge_account_id"], :name => "index_supplier_invoices_on_charge_account_id"
  add_index "supplier_invoices", ["invoice_date"], :name => "index_supplier_invoices_on_invoice_date"
  add_index "supplier_invoices", ["invoice_no"], :name => "index_supplier_invoices_on_invoice_no"
  add_index "supplier_invoices", ["payment_method_id"], :name => "index_supplier_invoices_on_payment_method_id"
  add_index "supplier_invoices", ["posted_at"], :name => "index_supplier_invoices_on_posted_at"
  add_index "supplier_invoices", ["project_id"], :name => "index_supplier_invoices_on_project_id"
  add_index "supplier_invoices", ["supplier_id"], :name => "index_supplier_invoices_on_supplier_id"
  add_index "supplier_invoices", ["work_order_id"], :name => "index_supplier_invoices_on_work_order_id"

  create_table "supplier_payments", :force => true do |t|
    t.integer  "supplier_id"
    t.integer  "supplier_invoice_id"
    t.integer  "payment_method_id"
    t.date     "payment_date"
    t.decimal  "amount",                        :precision => 13, :scale => 4, :default => 0.0, :null => false
    t.string   "remarks"
    t.integer  "approver_id"
    t.datetime "created_at",                                                                    :null => false
    t.datetime "updated_at",                                                                    :null => false
    t.integer  "supplier_invoice_approval__id"
    t.string   "payment_no"
  end

  add_index "supplier_payments", ["approver_id"], :name => "index_supplier_payments_on_approver_id"
  add_index "supplier_payments", ["payment_method_id"], :name => "index_supplier_payments_on_payment_method_id"
  add_index "supplier_payments", ["payment_no"], :name => "index_supplier_payments_on_payment_no"
  add_index "supplier_payments", ["supplier_id"], :name => "index_supplier_payments_on_supplier_id"
  add_index "supplier_payments", ["supplier_invoice_approval__id"], :name => "index_supplier_payments_on_supplier_invoice_approval__id"
  add_index "supplier_payments", ["supplier_invoice_id"], :name => "index_supplier_payments_on_supplier_invoice_id"

  create_table "suppliers", :force => true do |t|
    t.string   "name"
    t.string   "supplier_code"
    t.string   "fiscal_id"
    t.datetime "created_at",                                                        :null => false
    t.datetime "updated_at",                                                        :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.integer  "street_type_id"
    t.string   "street_name"
    t.string   "street_number"
    t.string   "building"
    t.integer  "floor"
    t.string   "floor_office"
    t.integer  "zipcode_id"
    t.integer  "town_id"
    t.integer  "province_id"
    t.string   "phone"
    t.string   "fax"
    t.string   "cellular"
    t.string   "email"
    t.integer  "region_id"
    t.integer  "country_id"
    t.integer  "payment_method_id"
    t.string   "ledger_account"
    t.decimal  "discount_rate",     :precision => 6,  :scale => 2, :default => 0.0, :null => false
    t.boolean  "active"
    t.integer  "max_orders_count",                                 :default => 0
    t.decimal  "max_orders_sum",    :precision => 13, :scale => 4, :default => 0.0, :null => false
    t.string   "contract_number"
    t.string   "remarks"
    t.integer  "entity_id"
  end

  add_index "suppliers", ["active"], :name => "index_suppliers_on_active"
  add_index "suppliers", ["cellular"], :name => "index_suppliers_on_cellular"
  add_index "suppliers", ["contract_number"], :name => "index_suppliers_on_contract_number"
  add_index "suppliers", ["country_id"], :name => "index_suppliers_on_country_id"
  add_index "suppliers", ["email"], :name => "index_suppliers_on_email"
  add_index "suppliers", ["entity_id"], :name => "index_suppliers_on_entity_id"
  add_index "suppliers", ["fax"], :name => "index_suppliers_on_fax"
  add_index "suppliers", ["fiscal_id"], :name => "index_suppliers_on_fiscal_id"
  add_index "suppliers", ["ledger_account"], :name => "index_suppliers_on_ledger_account"
  add_index "suppliers", ["name"], :name => "index_suppliers_on_name"
  add_index "suppliers", ["payment_method_id"], :name => "index_suppliers_on_payment_method_id"
  add_index "suppliers", ["phone"], :name => "index_suppliers_on_phone"
  add_index "suppliers", ["province_id"], :name => "index_suppliers_on_province_id"
  add_index "suppliers", ["region_id"], :name => "index_suppliers_on_region_id"
  add_index "suppliers", ["street_name"], :name => "index_suppliers_on_street_name"
  add_index "suppliers", ["street_type_id"], :name => "index_suppliers_on_street_type_id"
  add_index "suppliers", ["supplier_code"], :name => "index_suppliers_on_supplier_code"
  add_index "suppliers", ["town_id"], :name => "index_suppliers_on_town_id"
  add_index "suppliers", ["zipcode_id"], :name => "index_suppliers_on_zipcode_id"

  create_table "suppliers_activities", :id => false, :force => true do |t|
    t.integer "supplier_id"
    t.integer "activity_id"
  end

  add_index "suppliers_activities", ["supplier_id", "activity_id"], :name => "index_suppliers_activities_on_supplier_id_and_activity_id"

  create_table "tax_types", :force => true do |t|
    t.string   "description"
    t.decimal  "tax",         :precision => 6, :scale => 2, :default => 0.0, :null => false
    t.datetime "created_at",                                                 :null => false
    t.datetime "updated_at",                                                 :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.date     "expiration"
  end

  create_table "technicians", :force => true do |t|
    t.string   "name"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "technicians", ["name"], :name => "index_technicians_on_name"
  add_index "technicians", ["user_id"], :name => "index_technicians_on_user_id"

  create_table "ticket_categories", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "ticket_categories", ["name"], :name => "index_ticket_categories_on_name"

  create_table "ticket_priorities", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "ticket_priorities", ["name"], :name => "index_ticket_priorities_on_name"

  create_table "ticket_statuses", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "ticket_statuses", ["name"], :name => "index_ticket_statuses_on_name"

  create_table "tickets", :force => true do |t|
    t.integer  "ticket_category_id"
    t.integer  "ticket_priority_id"
    t.string   "ticket_subject"
    t.string   "ticket_message"
    t.integer  "ticket_status_id"
    t.integer  "technician_id"
    t.datetime "assign_at"
    t.datetime "status_changed_at"
    t.string   "status_changed_message"
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.integer  "office_id"
    t.string   "source_ip"
    t.string   "hd_email"
  end

  add_index "tickets", ["assign_at"], :name => "index_tickets_on_assign_at"
  add_index "tickets", ["created_at"], :name => "index_tickets_on_created_at"
  add_index "tickets", ["created_by"], :name => "index_tickets_on_created_by"
  add_index "tickets", ["office_id"], :name => "index_tickets_on_office_id"
  add_index "tickets", ["status_changed_at"], :name => "index_tickets_on_status_changed_at"
  add_index "tickets", ["technician_id"], :name => "index_tickets_on_technician_id"
  add_index "tickets", ["ticket_category_id"], :name => "index_tickets_on_ticket_category_id"
  add_index "tickets", ["ticket_priority_id"], :name => "index_tickets_on_ticket_priority_id"
  add_index "tickets", ["ticket_status_id"], :name => "index_tickets_on_ticket_status_id"
  add_index "tickets", ["ticket_subject"], :name => "index_tickets_on_ticket_subject"

  create_table "time_records", :force => true do |t|
    t.date     "timerecord_date"
    t.time     "timerecord_time"
    t.integer  "worker_id"
    t.integer  "timerecord_type_id"
    t.integer  "timerecord_code_id"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.string   "source_ip"
  end

  add_index "time_records", ["timerecord_code_id"], :name => "index_time_records_on_timerecord_code_id"
  add_index "time_records", ["timerecord_date"], :name => "index_time_records_on_timerecord_date"
  add_index "time_records", ["timerecord_time"], :name => "index_time_records_on_timerecord_time"
  add_index "time_records", ["timerecord_type_id"], :name => "index_time_records_on_timerecord_type_id"
  add_index "time_records", ["worker_id"], :name => "index_time_records_on_worker_id"

  create_table "timerecord_codes", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "timerecord_codes", ["name"], :name => "index_timerecord_codes_on_name"

  create_table "timerecord_reports", :force => true do |t|
    t.integer "tr_worker_id"
    t.date    "tr_date"
    t.time    "tr_time_1"
    t.integer "tr_type_id_1"
    t.integer "tr_code_id_1"
    t.time    "tr_time_2"
    t.integer "tr_type_id_2"
    t.integer "tr_code_id_2"
    t.time    "tr_time_3"
    t.integer "tr_type_id_3"
    t.integer "tr_code_id_3"
    t.time    "tr_time_4"
    t.integer "tr_type_id_4"
    t.integer "tr_code_id_4"
    t.time    "tr_time_5"
    t.integer "tr_type_id_5"
    t.integer "tr_code_id_5"
    t.time    "tr_time_6"
    t.integer "tr_type_id_6"
    t.integer "tr_code_id_6"
    t.time    "tr_time_7"
    t.integer "tr_type_id_7"
    t.integer "tr_code_id_7"
    t.time    "tr_time_8"
    t.integer "tr_type_id_8"
    t.integer "tr_code_id_8"
    t.time    "tr_worked_time"
    t.integer "tr_rec_count"
  end

  add_index "timerecord_reports", ["tr_code_id_1"], :name => "index_timerecord_reports_on_tr_code_id_1"
  add_index "timerecord_reports", ["tr_code_id_2"], :name => "index_timerecord_reports_on_tr_code_id_2"
  add_index "timerecord_reports", ["tr_code_id_3"], :name => "index_timerecord_reports_on_tr_code_id_3"
  add_index "timerecord_reports", ["tr_code_id_4"], :name => "index_timerecord_reports_on_tr_code_id_4"
  add_index "timerecord_reports", ["tr_code_id_5"], :name => "index_timerecord_reports_on_tr_code_id_5"
  add_index "timerecord_reports", ["tr_code_id_6"], :name => "index_timerecord_reports_on_tr_code_id_6"
  add_index "timerecord_reports", ["tr_code_id_7"], :name => "index_timerecord_reports_on_tr_code_id_7"
  add_index "timerecord_reports", ["tr_code_id_8"], :name => "index_timerecord_reports_on_tr_code_id_8"
  add_index "timerecord_reports", ["tr_date"], :name => "index_timerecord_reports_on_tr_date"
  add_index "timerecord_reports", ["tr_type_id_1"], :name => "index_timerecord_reports_on_tr_type_id_1"
  add_index "timerecord_reports", ["tr_type_id_2"], :name => "index_timerecord_reports_on_tr_type_id_2"
  add_index "timerecord_reports", ["tr_type_id_3"], :name => "index_timerecord_reports_on_tr_type_id_3"
  add_index "timerecord_reports", ["tr_type_id_4"], :name => "index_timerecord_reports_on_tr_type_id_4"
  add_index "timerecord_reports", ["tr_type_id_5"], :name => "index_timerecord_reports_on_tr_type_id_5"
  add_index "timerecord_reports", ["tr_type_id_6"], :name => "index_timerecord_reports_on_tr_type_id_6"
  add_index "timerecord_reports", ["tr_type_id_7"], :name => "index_timerecord_reports_on_tr_type_id_7"
  add_index "timerecord_reports", ["tr_type_id_8"], :name => "index_timerecord_reports_on_tr_type_id_8"
  add_index "timerecord_reports", ["tr_worker_id"], :name => "index_timerecord_reports_on_tr_worker_id"

  create_table "timerecord_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "timerecord_types", ["name"], :name => "index_timerecord_types_on_name"

  create_table "towns", :force => true do |t|
    t.string   "name"
    t.string   "ine_cmun"
    t.string   "ine_dc"
    t.integer  "province_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "towns", ["ine_cmun"], :name => "index_towns_on_ine_cmun"
  add_index "towns", ["province_id"], :name => "index_towns_on_province_id"

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "name",                   :default => "", :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "users_companies", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "company_id"
  end

  add_index "users_companies", ["user_id", "company_id"], :name => "index_users_companies_on_user_id_and_company_id"

  create_table "users_offices", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "office_id"
  end

  add_index "users_offices", ["user_id", "office_id"], :name => "index_users_offices_on_user_id_and_office_id"

  create_table "users_organizations", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "organization_id"
  end

  add_index "users_organizations", ["user_id", "organization_id"], :name => "index_users_organizations_on_user_id_and_organization_id"

  create_table "users_roles", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  add_index "users_roles", ["user_id", "role_id"], :name => "index_users_roles_on_user_id_and_role_id"

  create_table "versions", :force => true do |t|
    t.string   "item_type",  :null => false
    t.integer  "item_id",    :null => false
    t.string   "event",      :null => false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], :name => "index_versions_on_item_type_and_item_id"

  create_table "work_order_items", :force => true do |t|
    t.integer  "work_order_id"
    t.integer  "product_id"
    t.string   "description"
    t.decimal  "quantity",      :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.decimal  "cost",          :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.decimal  "price",         :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.integer  "tax_type_id"
    t.integer  "store_id"
    t.datetime "created_at",                                                    :null => false
    t.datetime "updated_at",                                                    :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "work_order_items", ["description"], :name => "index_work_order_items_on_description"
  add_index "work_order_items", ["product_id"], :name => "index_work_order_items_on_product_id"
  add_index "work_order_items", ["store_id"], :name => "index_work_order_items_on_store_id"
  add_index "work_order_items", ["tax_type_id"], :name => "index_work_order_items_on_tax_type_id"
  add_index "work_order_items", ["work_order_id"], :name => "index_work_order_items_on_work_order_id"

  create_table "work_order_labors", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  create_table "work_order_statuses", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  create_table "work_order_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  create_table "work_order_workers", :force => true do |t|
    t.integer  "work_order_id"
    t.integer  "worker_id"
    t.decimal  "hours",         :precision => 9,  :scale => 4, :default => 0.0, :null => false
    t.decimal  "cost",          :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.datetime "created_at",                                                    :null => false
    t.datetime "updated_at",                                                    :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "work_order_workers", ["work_order_id"], :name => "index_work_order_workers_on_work_order_id"
  add_index "work_order_workers", ["worker_id"], :name => "index_work_order_workers_on_worker_id"

  create_table "work_orders", :force => true do |t|
    t.string   "order_no"
    t.integer  "work_order_type_id"
    t.integer  "work_order_status_id"
    t.integer  "work_order_labor_id"
    t.datetime "started_at"
    t.datetime "completed_at"
    t.datetime "closed_at"
    t.integer  "charge_account_id"
    t.integer  "project_id"
    t.integer  "area_id"
    t.integer  "store_id"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.integer  "client_id"
    t.string   "remarks"
    t.string   "description"
    t.string   "petitioner"
    t.integer  "master_order_id"
    t.integer  "organization_id"
    t.integer  "in_charge_id"
    t.datetime "reported_at"
    t.datetime "approved_at"
    t.datetime "certified_at"
    t.datetime "posted_at"
    t.string   "location"
    t.string   "pub_record"
  end

  add_index "work_orders", ["area_id"], :name => "index_work_orders_on_area_id"
  add_index "work_orders", ["charge_account_id"], :name => "index_work_orders_on_charge_account_id"
  add_index "work_orders", ["client_id"], :name => "index_work_orders_on_client_id"
  add_index "work_orders", ["completed_at"], :name => "index_work_orders_on_completed_at"
  add_index "work_orders", ["in_charge_id"], :name => "index_work_orders_on_in_charge_id"
  add_index "work_orders", ["master_order_id"], :name => "index_work_orders_on_master_order_id"
  add_index "work_orders", ["order_no"], :name => "index_work_orders_on_order_no"
  add_index "work_orders", ["organization_id"], :name => "index_work_orders_on_organization_id"
  add_index "work_orders", ["project_id"], :name => "index_work_orders_on_project_id"
  add_index "work_orders", ["started_at"], :name => "index_work_orders_on_started_at"
  add_index "work_orders", ["store_id"], :name => "index_work_orders_on_store_id"
  add_index "work_orders", ["work_order_labor_id"], :name => "index_work_orders_on_work_order_labor_id"
  add_index "work_orders", ["work_order_status_id"], :name => "index_work_orders_on_work_order_status_id"
  add_index "work_orders", ["work_order_type_id"], :name => "index_work_orders_on_work_order_type_id"

  create_table "worker_items", :force => true do |t|
    t.integer  "worker_id"
    t.integer  "company_id"
    t.integer  "office_id"
    t.integer  "professional_group_id"
    t.integer  "collective_agreement_id"
    t.integer  "contract_type_id"
    t.string   "contribution_account_code"
    t.integer  "department_id"
    t.string   "position"
    t.integer  "insurance_id"
    t.string   "nomina_id"
    t.date     "starting_at"
    t.date     "ending_at"
    t.date     "issue_starting_at"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "worker_items", ["collective_agreement_id"], :name => "index_worker_items_on_collective_agreement_id"
  add_index "worker_items", ["company_id"], :name => "index_worker_items_on_company_id"
  add_index "worker_items", ["contract_type_id"], :name => "index_worker_items_on_contract_type_id"
  add_index "worker_items", ["contribution_account_code"], :name => "index_worker_items_on_contribution_account_code"
  add_index "worker_items", ["department_id"], :name => "index_worker_items_on_department_id"
  add_index "worker_items", ["insurance_id"], :name => "index_worker_items_on_insurance_id"
  add_index "worker_items", ["nomina_id"], :name => "index_worker_items_on_nomina_id"
  add_index "worker_items", ["office_id"], :name => "index_worker_items_on_office_id"
  add_index "worker_items", ["professional_group_id"], :name => "index_worker_items_on_professional_group_id"
  add_index "worker_items", ["worker_id"], :name => "index_worker_items_on_worker_id"

  create_table "worker_salaries", :force => true do |t|
    t.integer  "worker_item_id"
    t.integer  "year",                 :limit => 2
    t.decimal  "gross_salary",                      :precision => 12, :scale => 4, :default => 0.0,   :null => false
    t.decimal  "variable_salary",                   :precision => 12, :scale => 4, :default => 0.0,   :null => false
    t.decimal  "social_security_cost",              :precision => 12, :scale => 4, :default => 0.0,   :null => false
    t.decimal  "day_pct",                           :precision => 6,  :scale => 2, :default => 100.0, :null => false
    t.boolean  "active"
    t.datetime "created_at",                                                                          :null => false
    t.datetime "updated_at",                                                                          :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.decimal  "overtime",                          :precision => 12, :scale => 4, :default => 0.0,   :null => false
  end

  add_index "worker_salaries", ["worker_item_id"], :name => "index_worker_salaries_on_worker_item_id"
  add_index "worker_salaries", ["year"], :name => "index_worker_salaries_on_year"

  create_table "worker_salary_items", :force => true do |t|
    t.integer  "worker_salary_id"
    t.integer  "salary_concept_id"
    t.decimal  "amount",            :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.datetime "created_at",                                                        :null => false
    t.datetime "updated_at",                                                        :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "worker_salary_items", ["salary_concept_id"], :name => "index_worker_salary_items_on_salary_concept_id"
  add_index "worker_salary_items", ["worker_salary_id"], :name => "index_worker_salary_items_on_worker_salary_id"

  create_table "worker_types", :force => true do |t|
    t.string   "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  create_table "workers", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "worker_code"
    t.string   "fiscal_id"
    t.integer  "user_id"
    t.integer  "company_id"
    t.integer  "office_id"
    t.date     "starting_at"
    t.date     "ending_at"
    t.integer  "street_type_id"
    t.string   "street_name"
    t.string   "street_number"
    t.string   "building"
    t.integer  "floor"
    t.string   "floor_office"
    t.integer  "zipcode_id"
    t.integer  "town_id"
    t.integer  "province_id"
    t.string   "own_phone"
    t.string   "own_cellular"
    t.string   "email"
    t.datetime "created_at",                                                                :null => false
    t.datetime "updated_at",                                                                :null => false
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.integer  "professional_group_id"
    t.integer  "collective_agreement_id"
    t.integer  "degree_type_id"
    t.integer  "contract_type_id"
    t.date     "borned_on"
    t.date     "issue_starting_at"
    t.string   "affiliation_id"
    t.string   "contribution_account_code"
    t.string   "position"
    t.integer  "worker_type_id"
    t.string   "corp_phone"
    t.string   "corp_cellular_long"
    t.string   "corp_cellular_short"
    t.string   "corp_extension"
    t.integer  "department_id"
    t.string   "nomina_id"
    t.decimal  "gross_salary",              :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.decimal  "variable_salary",           :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.string   "remarks"
    t.decimal  "social_security_cost",      :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.string   "education"
    t.integer  "sex_id"
    t.integer  "insurance_id"
  end

  add_index "workers", ["affiliation_id"], :name => "index_workers_on_affiliation_id"
  add_index "workers", ["collective_agreement_id"], :name => "index_workers_on_collective_agreement_id"
  add_index "workers", ["company_id"], :name => "index_workers_on_company_id"
  add_index "workers", ["contract_type_id"], :name => "index_workers_on_contract_type_id"
  add_index "workers", ["contribution_account_code"], :name => "index_workers_on_contribution_account_code"
  add_index "workers", ["corp_cellular_long"], :name => "index_workers_on_corp_cellular_long"
  add_index "workers", ["corp_cellular_short"], :name => "index_workers_on_corp_cellular_short"
  add_index "workers", ["corp_extension"], :name => "index_workers_on_corp_extension"
  add_index "workers", ["corp_phone"], :name => "index_workers_on_corp_phone"
  add_index "workers", ["degree_type_id"], :name => "index_workers_on_degree_type_id"
  add_index "workers", ["department_id"], :name => "index_workers_on_department_id"
  add_index "workers", ["first_name"], :name => "index_workers_on_first_name"
  add_index "workers", ["fiscal_id"], :name => "index_workers_on_fiscal_id"
  add_index "workers", ["insurance_id"], :name => "index_workers_on_insurance_id"
  add_index "workers", ["last_name"], :name => "index_workers_on_last_name"
  add_index "workers", ["nomina_id"], :name => "index_workers_on_nomina_id"
  add_index "workers", ["office_id"], :name => "index_workers_on_office_id"
  add_index "workers", ["professional_group_id"], :name => "index_workers_on_professional_group_id"
  add_index "workers", ["province_id"], :name => "index_workers_on_province_id"
  add_index "workers", ["sex_id"], :name => "index_workers_on_sex_id"
  add_index "workers", ["street_type_id"], :name => "index_workers_on_street_type_id"
  add_index "workers", ["town_id"], :name => "index_workers_on_town_id"
  add_index "workers", ["user_id"], :name => "index_workers_on_user_id"
  add_index "workers", ["worker_code"], :name => "index_workers_on_worker_code"
  add_index "workers", ["worker_type_id"], :name => "index_workers_on_worker_type_id"
  add_index "workers", ["zipcode_id"], :name => "index_workers_on_zipcode_id"

  create_table "zipcodes", :force => true do |t|
    t.string   "zipcode"
    t.integer  "town_id"
    t.integer  "province_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "zipcodes", ["province_id"], :name => "index_zipcodes_on_province_id"
  add_index "zipcodes", ["town_id"], :name => "index_zipcodes_on_town_id"
  add_index "zipcodes", ["zipcode"], :name => "index_zipcodes_on_zipcode"

end
