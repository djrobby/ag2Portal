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

ActiveRecord::Schema.define(:version => 20151206190436) do

  create_table "accounting_groups", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "accounting_groups", ["code"], :name => "index_accounting_groups_on_code", :unique => true

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

  create_table "bank_account_classes", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "bank_account_classes", ["name"], :name => "index_bank_account_classes_on_name"

  create_table "bank_offices", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.integer  "bank_id"
    t.string   "swift"
    t.integer  "street_type_id"
    t.string   "street_name"
    t.string   "street_number"
    t.string   "building"
    t.string   "floor"
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
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "bank_offices", ["bank_id", "code"], :name => "index_bank_offices_on_bank_id_and_code", :unique => true
  add_index "bank_offices", ["bank_id"], :name => "index_bank_offices_on_bank_id"
  add_index "bank_offices", ["code"], :name => "index_bank_offices_on_code"
  add_index "bank_offices", ["country_id"], :name => "index_bank_offices_on_country_id"
  add_index "bank_offices", ["name"], :name => "index_bank_offices_on_name"
  add_index "bank_offices", ["province_id"], :name => "index_bank_offices_on_province_id"
  add_index "bank_offices", ["region_id"], :name => "index_bank_offices_on_region_id"
  add_index "bank_offices", ["street_type_id"], :name => "index_bank_offices_on_street_type_id"
  add_index "bank_offices", ["swift"], :name => "index_bank_offices_on_swift"
  add_index "bank_offices", ["town_id"], :name => "index_bank_offices_on_town_id"
  add_index "bank_offices", ["zipcode_id"], :name => "index_bank_offices_on_zipcode_id"

  create_table "banks", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.string   "swift"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "banks", ["code"], :name => "index_banks_on_code", :unique => true
  add_index "banks", ["name"], :name => "index_banks_on_name"
  add_index "banks", ["swift"], :name => "index_banks_on_swift"

  create_table "budget_groups", :force => true do |t|
    t.integer  "budget_id"
    t.integer  "charge_group_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "budget_groups", ["budget_id"], :name => "index_budget_groups_on_budget_id"
  add_index "budget_groups", ["charge_group_id"], :name => "index_budget_groups_on_charge_group_id"

  create_table "budget_headings", :force => true do |t|
    t.string   "heading_code"
    t.string   "name"
    t.integer  "organization_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "budget_headings", ["heading_code"], :name => "index_budget_headings_on_heading_code"
  add_index "budget_headings", ["organization_id", "heading_code"], :name => "index_budget_headings_on_organization_and_code", :unique => true
  add_index "budget_headings", ["organization_id"], :name => "index_budget_headings_on_organization_id"

  create_table "budget_items", :force => true do |t|
    t.integer  "budget_id"
    t.integer  "charge_account_id"
    t.decimal  "amount",            :precision => 13, :scale => 4, :default => 0.0, :null => false
    t.decimal  "corrected_amount",  :precision => 13, :scale => 4, :default => 0.0, :null => false
    t.datetime "created_at",                                                        :null => false
    t.datetime "updated_at",                                                        :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.decimal  "month_01",          :precision => 13, :scale => 4, :default => 0.0, :null => false
    t.decimal  "month_02",          :precision => 13, :scale => 4, :default => 0.0, :null => false
    t.decimal  "month_03",          :precision => 13, :scale => 4, :default => 0.0, :null => false
    t.decimal  "month_04",          :precision => 13, :scale => 4, :default => 0.0, :null => false
    t.decimal  "month_05",          :precision => 13, :scale => 4, :default => 0.0, :null => false
    t.decimal  "month_06",          :precision => 13, :scale => 4, :default => 0.0, :null => false
    t.decimal  "month_07",          :precision => 13, :scale => 4, :default => 0.0, :null => false
    t.decimal  "month_08",          :precision => 13, :scale => 4, :default => 0.0, :null => false
    t.decimal  "month_09",          :precision => 13, :scale => 4, :default => 0.0, :null => false
    t.decimal  "month_10",          :precision => 13, :scale => 4, :default => 0.0, :null => false
    t.decimal  "month_11",          :precision => 13, :scale => 4, :default => 0.0, :null => false
    t.decimal  "month_12",          :precision => 13, :scale => 4, :default => 0.0, :null => false
  end

  add_index "budget_items", ["budget_id"], :name => "index_budget_items_on_budget_id"
  add_index "budget_items", ["charge_account_id"], :name => "index_budget_items_on_charge_account_id"

  create_table "budget_periods", :force => true do |t|
    t.string   "period_code"
    t.string   "name"
    t.datetime "starting_at"
    t.datetime "ending_at"
    t.integer  "organization_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "budget_periods", ["ending_at"], :name => "index_budget_periods_on_ending_at"
  add_index "budget_periods", ["name"], :name => "index_budget_periods_on_name"
  add_index "budget_periods", ["organization_id", "period_code"], :name => "index_budget_periods_on_organization_and_code", :unique => true
  add_index "budget_periods", ["organization_id"], :name => "index_budget_periods_on_organization_id"
  add_index "budget_periods", ["period_code"], :name => "index_budget_periods_on_period_code"
  add_index "budget_periods", ["starting_at"], :name => "index_budget_periods_on_starting_at"

  create_table "budget_ratios", :force => true do |t|
    t.integer  "budget_id"
    t.integer  "ratio_id"
    t.decimal  "amount",     :precision => 13, :scale => 4, :default => 0.0, :null => false
    t.decimal  "month_01",   :precision => 13, :scale => 4, :default => 0.0, :null => false
    t.decimal  "month_02",   :precision => 13, :scale => 4, :default => 0.0, :null => false
    t.decimal  "month_03",   :precision => 13, :scale => 4, :default => 0.0, :null => false
    t.decimal  "month_04",   :precision => 13, :scale => 4, :default => 0.0, :null => false
    t.decimal  "month_05",   :precision => 13, :scale => 4, :default => 0.0, :null => false
    t.decimal  "month_06",   :precision => 13, :scale => 4, :default => 0.0, :null => false
    t.decimal  "month_07",   :precision => 13, :scale => 4, :default => 0.0, :null => false
    t.decimal  "month_08",   :precision => 13, :scale => 4, :default => 0.0, :null => false
    t.decimal  "month_09",   :precision => 13, :scale => 4, :default => 0.0, :null => false
    t.decimal  "month_10",   :precision => 13, :scale => 4, :default => 0.0, :null => false
    t.decimal  "month_11",   :precision => 13, :scale => 4, :default => 0.0, :null => false
    t.decimal  "month_12",   :precision => 13, :scale => 4, :default => 0.0, :null => false
    t.datetime "created_at",                                                 :null => false
    t.datetime "updated_at",                                                 :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "budget_ratios", ["budget_id"], :name => "index_budget_ratios_on_budget_id"
  add_index "budget_ratios", ["ratio_id"], :name => "index_budget_ratios_on_ratio_id"

  create_table "budgets", :force => true do |t|
    t.string   "budget_no"
    t.string   "description"
    t.integer  "project_id"
    t.integer  "organization_id"
    t.integer  "budget_period_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.integer  "approver_id"
    t.datetime "approval_date"
  end

  add_index "budgets", ["approver_id"], :name => "index_budgets_on_approver_id"
  add_index "budgets", ["budget_no"], :name => "index_budgets_on_budget_no"
  add_index "budgets", ["budget_period_id"], :name => "index_budgets_on_budget_period_id"
  add_index "budgets", ["organization_id", "budget_no"], :name => "index_budgets_on_organization_and_code", :unique => true
  add_index "budgets", ["organization_id"], :name => "index_budgets_on_organization_id"
  add_index "budgets", ["project_id"], :name => "index_budgets_on_project_id"

  create_table "charge_accounts", :force => true do |t|
    t.string   "name"
    t.date     "opened_at"
    t.date     "closed_at"
    t.integer  "project_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.string   "account_code"
    t.integer  "organization_id"
    t.integer  "charge_group_id"
    t.integer  "ledger_account_id"
  end

  add_index "charge_accounts", ["account_code"], :name => "index_charge_accounts_on_account_code"
  add_index "charge_accounts", ["charge_group_id"], :name => "index_charge_accounts_on_charge_group_id"
  add_index "charge_accounts", ["ledger_account_id"], :name => "index_charge_accounts_on_ledger_account_id"
  add_index "charge_accounts", ["name"], :name => "index_charge_accounts_on_name"
  add_index "charge_accounts", ["organization_id", "account_code"], :name => "index_charge_accounts_on_organization_id_and_account_code", :unique => true
  add_index "charge_accounts", ["organization_id"], :name => "index_charge_accounts_on_organization_id"
  add_index "charge_accounts", ["project_id"], :name => "index_charge_accounts_on_project_id"

  create_table "charge_groups", :force => true do |t|
    t.string   "group_code"
    t.string   "name"
    t.integer  "flow",              :limit => 2
    t.integer  "organization_id"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.integer  "budget_heading_id"
    t.integer  "ledger_account_id"
  end

  add_index "charge_groups", ["budget_heading_id"], :name => "index_charge_groups_on_budget_heading_id"
  add_index "charge_groups", ["flow"], :name => "index_charge_groups_on_flow"
  add_index "charge_groups", ["group_code"], :name => "index_charge_groups_on_group_code"
  add_index "charge_groups", ["ledger_account_id"], :name => "index_charge_groups_on_ledger_account_id"
  add_index "charge_groups", ["name"], :name => "index_charge_groups_on_name"
  add_index "charge_groups", ["organization_id", "group_code"], :name => "index_charge_groups_on_organization_and_code", :unique => true
  add_index "charge_groups", ["organization_id"], :name => "index_charge_groups_on_organization_id"

  create_table "clients", :force => true do |t|
    t.integer  "entity_id"
    t.string   "client_code"
    t.string   "name"
    t.string   "fiscal_id"
    t.integer  "street_type_id"
    t.string   "street_name"
    t.string   "street_number"
    t.string   "building"
    t.string   "floor"
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
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.integer  "organization_id"
    t.boolean  "is_contact"
    t.integer  "shared_contact_id"
    t.integer  "ledger_account_id"
    t.integer  "payment_method_id"
  end

  add_index "clients", ["client_code"], :name => "index_clients_on_client_code"
  add_index "clients", ["country_id"], :name => "index_clients_on_country_id"
  add_index "clients", ["entity_id"], :name => "index_clients_on_entity_id"
  add_index "clients", ["fiscal_id"], :name => "index_clients_on_fiscal_id"
  add_index "clients", ["ledger_account_id"], :name => "index_clients_on_ledger_account_id"
  add_index "clients", ["name"], :name => "index_clients_on_name"
  add_index "clients", ["organization_id", "client_code"], :name => "index_clients_on_organization_id_and_client_code", :unique => true
  add_index "clients", ["organization_id", "fiscal_id"], :name => "index_clients_on_organization_id_and_fiscal_id", :unique => true
  add_index "clients", ["organization_id"], :name => "index_clients_on_organization_id"
  add_index "clients", ["payment_method_id"], :name => "index_clients_on_payment_method_id"
  add_index "clients", ["province_id"], :name => "index_clients_on_province_id"
  add_index "clients", ["region_id"], :name => "index_clients_on_region_id"
  add_index "clients", ["shared_contact_id"], :name => "index_clients_on_shared_contact_id"
  add_index "clients", ["street_type_id"], :name => "index_clients_on_street_type_id"
  add_index "clients", ["town_id"], :name => "index_clients_on_town_id"
  add_index "clients", ["zipcode_id"], :name => "index_clients_on_zipcode_id"

  create_table "collective_agreements", :force => true do |t|
    t.string   "name"
    t.string   "ca_code"
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.string   "nomina_id"
    t.integer  "hours",           :limit => 2, :default => 0
    t.integer  "organization_id"
  end

  add_index "collective_agreements", ["ca_code"], :name => "index_collective_agreements_on_ca_code"
  add_index "collective_agreements", ["nomina_id"], :name => "index_collective_agreements_on_nomina_id"
  add_index "collective_agreements", ["organization_id", "ca_code"], :name => "index_collective_agreements_on_organization_id_and_ca_code", :unique => true
  add_index "collective_agreements", ["organization_id"], :name => "index_collective_agreements_on_organization_id"

  create_table "companies", :force => true do |t|
    t.string   "name"
    t.string   "fiscal_id"
    t.datetime "created_at",                                                          :null => false
    t.datetime "updated_at",                                                          :null => false
    t.integer  "street_type_id"
    t.string   "street_name"
    t.string   "street_number"
    t.string   "building"
    t.string   "floor"
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
    t.decimal  "max_order_total",     :precision => 13, :scale => 4, :default => 0.0, :null => false
    t.decimal  "max_order_price",     :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.string   "website"
    t.decimal  "overtime_pct",        :precision => 6,  :scale => 2, :default => 0.0, :null => false
  end

  add_index "companies", ["fiscal_id"], :name => "index_companies_on_fiscal_id"
  add_index "companies", ["invoice_code"], :name => "index_companies_on_invoice_code"
  add_index "companies", ["organization_id", "fiscal_id"], :name => "index_companies_on_organization_id_and_fiscal_id", :unique => true
  add_index "companies", ["organization_id"], :name => "index_companies_on_organization_id"
  add_index "companies", ["province_id"], :name => "index_companies_on_province_id"
  add_index "companies", ["street_type_id"], :name => "index_companies_on_street_type_id"
  add_index "companies", ["town_id"], :name => "index_companies_on_town_id"
  add_index "companies", ["zipcode_id"], :name => "index_companies_on_zipcode_id"

  create_table "company_notifications", :force => true do |t|
    t.integer  "company_id"
    t.integer  "notification_id"
    t.integer  "user_id"
    t.integer  "role",            :limit => 2
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
  end

  add_index "company_notifications", ["company_id"], :name => "index_company_notifications_on_company_id"
  add_index "company_notifications", ["notification_id"], :name => "index_company_notifications_on_notification_id"
  add_index "company_notifications", ["role"], :name => "index_company_notifications_on_role"
  add_index "company_notifications", ["user_id"], :name => "index_company_notifications_on_user_id"

  create_table "contract_types", :force => true do |t|
    t.string   "name"
    t.string   "ct_code"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.string   "nomina_id"
    t.integer  "organization_id"
  end

  add_index "contract_types", ["ct_code"], :name => "index_contract_types_on_ct_code"
  add_index "contract_types", ["nomina_id"], :name => "index_contract_types_on_nomina_id"
  add_index "contract_types", ["organization_id", "ct_code"], :name => "index_contract_types_on_organization_id_and_ct_code", :unique => true
  add_index "contract_types", ["organization_id"], :name => "index_contract_types_on_organization_id"

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
    t.datetime "created_at",                                         :null => false
    t.datetime "updated_at",                                         :null => false
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.integer  "worker_id"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.integer  "worker_count",        :limit => 2
    t.integer  "organization_id"
    t.boolean  "real_email",                       :default => true
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
  add_index "corp_contacts", ["organization_id"], :name => "index_corp_contacts_on_organization_id"
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
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.string   "nomina_id"
    t.integer  "organization_id"
  end

  add_index "degree_types", ["dt_code"], :name => "index_degree_types_on_dt_code"
  add_index "degree_types", ["nomina_id"], :name => "index_degree_types_on_nomina_id"
  add_index "degree_types", ["organization_id", "dt_code"], :name => "index_degree_types_on_organization_id_and_dt_code", :unique => true
  add_index "degree_types", ["organization_id"], :name => "index_degree_types_on_organization_id"

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
    t.integer  "organization_id"
  end

  add_index "delivery_notes", ["charge_account_id"], :name => "index_delivery_notes_on_charge_account_id"
  add_index "delivery_notes", ["client_id"], :name => "index_delivery_notes_on_client_id"
  add_index "delivery_notes", ["delivery_date"], :name => "index_delivery_notes_on_delivery_date"
  add_index "delivery_notes", ["delivery_no"], :name => "index_delivery_notes_on_delivery_no"
  add_index "delivery_notes", ["organization_id", "delivery_no"], :name => "index_delivery_notes_on_organization_id_and_delivery_no", :unique => true
  add_index "delivery_notes", ["organization_id"], :name => "index_delivery_notes_on_organization_id"
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
  add_index "departments", ["organization_id", "code"], :name => "index_departments_on_organization_id_and_code", :unique => true
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
    t.string   "floor"
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
  add_index "entities", ["fiscal_id"], :name => "index_entities_on_fiscal_id"
  add_index "entities", ["last_name"], :name => "index_entities_on_last_name"
  add_index "entities", ["organization_id", "fiscal_id"], :name => "index_entities_on_organization_id_and_fiscal_id", :unique => true
  add_index "entities", ["organization_id"], :name => "index_entities_on_organization_id"
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
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.integer  "organization_id"
  end

  add_index "insurances", ["name"], :name => "index_insurances_on_name"
  add_index "insurances", ["organization_id"], :name => "index_insurances_on_organization_id"

  create_table "inventory_count_items", :force => true do |t|
    t.integer  "inventory_count_id"
    t.integer  "product_id"
    t.decimal  "quantity",           :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.datetime "created_at",                                                         :null => false
    t.datetime "updated_at",                                                         :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.decimal  "initial",            :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.decimal  "current",            :precision => 12, :scale => 4, :default => 0.0, :null => false
  end

  add_index "inventory_count_items", ["inventory_count_id"], :name => "index_inventory_count_items_on_inventory_count_id"
  add_index "inventory_count_items", ["product_id"], :name => "index_inventory_count_items_on_product_id"

  create_table "inventory_count_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  create_table "inventory_counts", :force => true do |t|
    t.string   "count_no"
    t.date     "count_date"
    t.integer  "inventory_count_type_id"
    t.integer  "store_id"
    t.integer  "product_family_id"
    t.integer  "organization_id"
    t.string   "remarks"
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.integer  "approver_id"
    t.datetime "approval_date"
  end

  add_index "inventory_counts", ["approver_id"], :name => "index_inventory_counts_on_approver_id"
  add_index "inventory_counts", ["count_date"], :name => "index_inventory_counts_on_count_date"
  add_index "inventory_counts", ["count_no"], :name => "index_inventory_counts_on_count_no"
  add_index "inventory_counts", ["inventory_count_type_id"], :name => "index_inventory_counts_on_inventory_count_type_id"
  add_index "inventory_counts", ["organization_id", "count_no"], :name => "index_inventory_counts_on_organization_id_and_count_no", :unique => true
  add_index "inventory_counts", ["organization_id"], :name => "index_inventory_counts_on_organization_id"
  add_index "inventory_counts", ["product_family_id"], :name => "index_inventory_counts_on_product_family_id"
  add_index "inventory_counts", ["store_id"], :name => "index_inventory_counts_on_store_id"

  create_table "ledger_accounts", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.integer  "accounting_group_id"
    t.integer  "project_id"
    t.integer  "organization_id"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "ledger_accounts", ["accounting_group_id"], :name => "index_ledger_accounts_on_accounting_group_id"
  add_index "ledger_accounts", ["code"], :name => "index_ledger_accounts_on_code"
  add_index "ledger_accounts", ["organization_id", "code"], :name => "index_ledger_accounts_on_organization_and_code", :unique => true
  add_index "ledger_accounts", ["organization_id"], :name => "index_ledger_accounts_on_organization_id"
  add_index "ledger_accounts", ["project_id"], :name => "index_ledger_accounts_on_project_id"

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

  create_table "notifications", :force => true do |t|
    t.string   "name"
    t.string   "table"
    t.integer  "action",     :limit => 2
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "notifications", ["action"], :name => "index_notifications_on_action"
  add_index "notifications", ["table"], :name => "index_notifications_on_table"

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
    t.integer  "organization_id"
  end

  add_index "offer_requests", ["approved_offer_id"], :name => "index_offer_requests_on_approved_offer_id"
  add_index "offer_requests", ["approver_id"], :name => "index_offer_requests_on_approver_id"
  add_index "offer_requests", ["charge_account_id"], :name => "index_offer_requests_on_charge_account_id"
  add_index "offer_requests", ["organization_id", "request_no"], :name => "index_offer_requests_on_organization_id_and_request_no", :unique => true
  add_index "offer_requests", ["organization_id"], :name => "index_offer_requests_on_organization_id"
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
    t.datetime "created_at",                                                              :null => false
    t.datetime "updated_at",                                                              :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.decimal  "discount_pct",            :precision => 6,  :scale => 2, :default => 0.0, :null => false
    t.decimal  "discount",                :precision => 13, :scale => 4, :default => 0.0, :null => false
    t.integer  "project_id"
    t.integer  "store_id"
    t.integer  "work_order_id"
    t.integer  "charge_account_id"
    t.integer  "organization_id"
    t.integer  "approver_id"
    t.datetime "approval_date"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
  end

  add_index "offers", ["approver_id"], :name => "index_offers_on_approver_id"
  add_index "offers", ["charge_account_id"], :name => "index_offers_on_charge_account_id"
  add_index "offers", ["offer_date"], :name => "index_offers_on_offer_date"
  add_index "offers", ["offer_no"], :name => "index_offers_on_offer_no"
  add_index "offers", ["offer_request_id"], :name => "index_offers_on_offer_request_id"
  add_index "offers", ["organization_id", "supplier_id", "offer_no"], :name => "index_offers_on_organization_id_and_supplier_id_and_offer_no", :unique => true
  add_index "offers", ["organization_id"], :name => "index_offers_on_organization_id"
  add_index "offers", ["payment_method_id"], :name => "index_offers_on_payment_method_id"
  add_index "offers", ["project_id"], :name => "index_offers_on_project_id"
  add_index "offers", ["store_id"], :name => "index_offers_on_store_id"
  add_index "offers", ["supplier_id"], :name => "index_offers_on_supplier_id"
  add_index "offers", ["work_order_id"], :name => "index_offers_on_work_order_id"

  create_table "office_notifications", :force => true do |t|
    t.integer  "office_id"
    t.integer  "notification_id"
    t.integer  "user_id"
    t.integer  "role",            :limit => 2
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
  end

  add_index "office_notifications", ["notification_id"], :name => "index_office_notifications_on_notification_id"
  add_index "office_notifications", ["office_id"], :name => "index_office_notifications_on_office_id"
  add_index "office_notifications", ["role"], :name => "index_office_notifications_on_role"
  add_index "office_notifications", ["user_id"], :name => "index_office_notifications_on_user_id"

  create_table "offices", :force => true do |t|
    t.string   "name"
    t.integer  "company_id"
    t.datetime "created_at",                                                      :null => false
    t.datetime "updated_at",                                                      :null => false
    t.string   "office_code"
    t.integer  "street_type_id"
    t.string   "street_name"
    t.string   "street_number"
    t.string   "building"
    t.string   "floor"
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
    t.decimal  "max_order_total", :precision => 13, :scale => 4, :default => 0.0, :null => false
    t.decimal  "max_order_price", :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.decimal  "overtime_pct",    :precision => 6,  :scale => 2, :default => 0.0, :null => false
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
    t.integer  "organization_id"
  end

  add_index "payment_methods", ["description"], :name => "index_payment_methods_on_description"
  add_index "payment_methods", ["flow"], :name => "index_payment_methods_on_flow"
  add_index "payment_methods", ["organization_id"], :name => "index_payment_methods_on_organization_id"

  create_table "product_families", :force => true do |t|
    t.string   "name"
    t.string   "family_code"
    t.integer  "max_orders_count",                                   :default => 0
    t.decimal  "max_orders_sum",      :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.datetime "created_at",                                                          :null => false
    t.datetime "updated_at",                                                          :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.integer  "organization_id"
    t.boolean  "order_authorization"
  end

  add_index "product_families", ["family_code"], :name => "index_product_families_on_family_code"
  add_index "product_families", ["name"], :name => "index_product_families_on_name"
  add_index "product_families", ["organization_id", "family_code"], :name => "index_product_families_on_organization_id_and_family_code", :unique => true
  add_index "product_families", ["organization_id"], :name => "index_product_families_on_organization_id"

