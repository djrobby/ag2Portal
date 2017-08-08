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

ActiveRecord::Schema.define(:version => 20170808102152) do

  create_table "accounting_groups", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "accounting_groups", ["code"], :name => "index_accounting_groups_on_code", :unique => true

  create_table "active_invoices", :id => false, :force => true do |t|
    t.integer "billing_period_id"
    t.integer "client_id"
    t.integer "subscriber_id"
    t.integer "invoice_type_id"
    t.integer "invoice_operation_id"
    t.integer "bill_id",              :default => 0, :null => false
    t.integer "invoice_id",           :default => 0, :null => false
    t.integer "original_invoice_id"
  end

  create_table "active_supply_invoices", :id => false, :force => true do |t|
    t.integer "billing_period_id"
    t.integer "client_id"
    t.integer "subscriber_id"
    t.integer "invoice_type_id"
    t.integer "invoice_operation_id"
    t.integer "bill_id",              :default => 0, :null => false
    t.integer "invoice_id",           :default => 0, :null => false
    t.integer "original_invoice_id"
    t.integer "pre_invoice_id",       :default => 0, :null => false
  end

  create_table "active_tariffs", :id => false, :force => true do |t|
    t.integer "tariff_id",                                                                 :default => 0,   :null => false
    t.integer "billable_item_id"
    t.integer "project_id"
    t.string  "project_code"
    t.integer "tariff_type_id"
    t.string  "tariff_type_code"
    t.integer "billable_concept_id"
    t.string  "billable_concept_code"
    t.integer "caliber_id"
    t.integer "caliber",                       :limit => 2,                                :default => 0,   :null => false
    t.integer "billing_frequency_id"
    t.string  "billing_frequency_name"
    t.date    "starting_at"
    t.decimal "fixed_fee",                                  :precision => 12, :scale => 6, :default => 0.0, :null => false
    t.decimal "variable_fee",                               :precision => 12, :scale => 6, :default => 0.0, :null => false
    t.decimal "percentage_fee",                             :precision => 6,  :scale => 2, :default => 0.0, :null => false
    t.string  "percentage_applicable_formula"
    t.integer "block1_limit"
    t.integer "block2_limit"
    t.integer "block3_limit"
    t.integer "block4_limit"
    t.integer "block5_limit"
    t.integer "block6_limit"
    t.integer "block7_limit"
    t.integer "block8_limit"
    t.decimal "block1_fee",                                 :precision => 12, :scale => 6, :default => 0.0, :null => false
    t.decimal "block2_fee",                                 :precision => 12, :scale => 6, :default => 0.0, :null => false
    t.decimal "block3_fee",                                 :precision => 12, :scale => 6, :default => 0.0, :null => false
    t.decimal "block4_fee",                                 :precision => 12, :scale => 6, :default => 0.0, :null => false
    t.decimal "block5_fee",                                 :precision => 12, :scale => 6, :default => 0.0, :null => false
    t.decimal "block6_fee",                                 :precision => 12, :scale => 6, :default => 0.0, :null => false
    t.decimal "block7_fee",                                 :precision => 12, :scale => 6, :default => 0.0, :null => false
    t.decimal "block8_fee",                                 :precision => 12, :scale => 6, :default => 0.0, :null => false
    t.decimal "discount_pct_f",                             :precision => 6,  :scale => 2, :default => 0.0, :null => false
    t.decimal "discount_pct_v",                             :precision => 6,  :scale => 2, :default => 0.0, :null => false
    t.decimal "discount_pct_p",                             :precision => 6,  :scale => 2, :default => 0.0, :null => false
    t.decimal "discount_pct_b",                             :precision => 6,  :scale => 2, :default => 0.0, :null => false
    t.integer "tax_type_f_id"
    t.integer "tax_type_v_id"
    t.integer "tax_type_p_id"
    t.integer "tax_type_b_id"
    t.decimal "percentage_fixed_fee",                       :precision => 6,  :scale => 2, :default => 0.0, :null => false
  end

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

  create_table "background_works", :force => true do |t|
    t.integer  "user_id"
    t.string   "work_no"
    t.integer  "group_no"
    t.integer  "total"
    t.text     "failure"
    t.string   "status"
    t.string   "type_work"
    t.boolean  "complete",                                       :default => false
    t.integer  "consumption"
    t.decimal  "price_total",     :precision => 12, :scale => 4, :default => 0.0,   :null => false
    t.integer  "total_confirmed"
    t.date     "invoice_date"
    t.date     "payday_limit"
    t.string   "first_bill"
    t.string   "last_bill"
    t.datetime "created_at",                                                        :null => false
    t.datetime "updated_at",                                                        :null => false
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

  create_table "billable_concepts", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.string   "billable_document"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "billable_concepts", ["code"], :name => "index_billable_concepts_on_code", :unique => true

  create_table "billable_items", :force => true do |t|
    t.integer  "project_id"
    t.integer  "billable_concept_id"
    t.integer  "biller_id"
    t.integer  "regulation_id"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.boolean  "tariffs_by_caliber",  :default => false
  end

  add_index "billable_items", ["billable_concept_id"], :name => "index_billable_items_on_billable_concept_id"
  add_index "billable_items", ["biller_id"], :name => "index_billable_items_on_biller_id"
  add_index "billable_items", ["project_id", "billable_concept_id", "biller_id", "regulation_id"], :name => "index_billable_items_unique", :unique => true
  add_index "billable_items", ["project_id"], :name => "index_billable_items_on_project_id"
  add_index "billable_items", ["regulation_id"], :name => "index_billable_items_on_regulation_id"

  create_table "billing_frequencies", :force => true do |t|
    t.string   "name"
    t.integer  "months",         :limit => 2, :default => 0, :null => false
    t.integer  "days",           :limit => 2, :default => 0, :null => false
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.integer  "fix_measure_id"
    t.integer  "var_measure_id"
  end

  add_index "billing_frequencies", ["fix_measure_id"], :name => "index_billing_frequencies_on_fix_measure_id"
  add_index "billing_frequencies", ["var_measure_id"], :name => "index_billing_frequencies_on_var_measure_id"

  create_table "billing_incidence_types", :force => true do |t|
    t.string   "name"
    t.boolean  "is_main"
    t.string   "code",       :limit => 2
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "billing_incidence_types", ["code"], :name => "index_billing_incidence_types_on_code"

  create_table "billing_periods", :force => true do |t|
    t.integer  "project_id"
    t.integer  "billing_frequency_id"
    t.integer  "period"
    t.string   "description"
    t.date     "reading_starting_date"
    t.date     "reading_ending_date"
    t.date     "prebilling_starting_date"
    t.date     "prebilling_ending_date"
    t.date     "billing_starting_date"
    t.date     "billing_ending_date"
    t.date     "charging_starting_date"
    t.date     "charging_ending_date"
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "billing_periods", ["billing_frequency_id"], :name => "index_billing_periods_on_billing_frequency_id"
  add_index "billing_periods", ["period"], :name => "index_billing_periods_on_period"
  add_index "billing_periods", ["project_id", "period"], :name => "index_billing_periods_unique", :unique => true
  add_index "billing_periods", ["project_id"], :name => "index_billing_periods_on_project_id"

  create_table "bills", :force => true do |t|
    t.string   "bill_no"
    t.integer  "project_id"
    t.integer  "client_id"
    t.integer  "subscriber_id"
    t.integer  "invoice_status_id"
    t.date     "bill_date"
    t.string   "last_name"
    t.string   "first_name"
    t.string   "company"
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
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.integer  "reading_1_id"
    t.integer  "reading_2_id"
    t.string   "remarks"
    t.integer  "organization_id"
    t.integer  "payment_method_id"
  end

  add_index "bills", ["client_id"], :name => "index_bills_on_client_id"
  add_index "bills", ["country_id"], :name => "index_bills_on_country_id"
  add_index "bills", ["invoice_status_id"], :name => "index_bills_on_invoice_status_id"
  add_index "bills", ["organization_id"], :name => "index_bills_on_organization_id"
  add_index "bills", ["payment_method_id"], :name => "index_bills_on_payment_method_id"
  add_index "bills", ["project_id"], :name => "index_bills_on_project_id"
  add_index "bills", ["province_id"], :name => "index_bills_on_province_id"
  add_index "bills", ["region_id"], :name => "index_bills_on_region_id"
  add_index "bills", ["street_type_id"], :name => "index_bills_on_street_type_id"
  add_index "bills", ["subscriber_id"], :name => "index_bills_on_subscriber_id"
  add_index "bills", ["town_id"], :name => "index_bills_on_town_id"
  add_index "bills", ["zipcode_id"], :name => "index_bills_on_zipcode_id"

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

  create_table "calibers", :force => true do |t|
    t.integer  "caliber",      :limit => 2,                               :default => 0,   :null => false
    t.datetime "created_at",                                                               :null => false
    t.datetime "updated_at",                                                               :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.string   "letter_id",    :limit => 1
    t.decimal  "nominal_flow",              :precision => 9, :scale => 3, :default => 0.0, :null => false
  end

  add_index "calibers", ["caliber"], :name => "index_calibers_on_caliber"

  create_table "cancelled_invoices", :id => false, :force => true do |t|
    t.integer "billing_period_id"
    t.integer "client_id"
    t.integer "subscriber_id"
    t.integer "invoice_type_id"
    t.integer "invoice_operation_id"
    t.integer "bill_id",              :default => 0, :null => false
    t.integer "invoice_id",           :default => 0, :null => false
    t.integer "original_invoice_id"
    t.integer "credit_invoice_id",    :default => 0, :null => false
  end

  create_table "cash_desk_closing_instruments", :force => true do |t|
    t.integer  "cash_desk_closing_id"
    t.integer  "currency_instrument_id"
    t.decimal  "amount",                              :precision => 13, :scale => 4, :default => 0.0, :null => false
    t.datetime "created_at",                                                                          :null => false
    t.datetime "updated_at",                                                                          :null => false
    t.integer  "quantity",               :limit => 2,                                :default => 0,   :null => false
  end

  add_index "cash_desk_closing_instruments", ["cash_desk_closing_id"], :name => "index_cash_desk_closing_instruments_on_cash_desk_closing_id"
  add_index "cash_desk_closing_instruments", ["currency_instrument_id"], :name => "index_cash_desk_closing_instruments_on_currency_instrument_id"

  create_table "cash_desk_closing_items", :force => true do |t|
    t.integer  "cash_desk_closing_id"
    t.integer  "client_payment_id"
    t.integer  "supplier_payment_id"
    t.string   "type_i",               :limit => 1,                                                 :null => false
    t.decimal  "amount",                            :precision => 13, :scale => 4, :default => 0.0, :null => false
    t.datetime "created_at",                                                                        :null => false
    t.datetime "updated_at",                                                                        :null => false
  end

  add_index "cash_desk_closing_items", ["cash_desk_closing_id"], :name => "index_cash_desk_closing_items_on_cash_desk_closing_id"
  add_index "cash_desk_closing_items", ["client_payment_id"], :name => "index_cash_desk_closing_items_on_client_payment_id"
  add_index "cash_desk_closing_items", ["supplier_payment_id"], :name => "index_cash_desk_closing_items_on_supplier_payment_id"
  add_index "cash_desk_closing_items", ["type_i"], :name => "index_cash_desk_closing_items_on_type_i"

  create_table "cash_desk_closings", :force => true do |t|
    t.integer  "organization_id"
    t.integer  "company_id"
    t.integer  "office_id"
    t.integer  "project_id"
    t.decimal  "opening_balance",    :precision => 13, :scale => 4, :default => 0.0, :null => false
    t.decimal  "closing_balance",    :precision => 13, :scale => 4, :default => 0.0, :null => false
    t.decimal  "amount_collected",   :precision => 13, :scale => 4, :default => 0.0, :null => false
    t.integer  "invoices_collected",                                :default => 0,   :null => false
    t.datetime "created_at",                                                         :null => false
    t.datetime "updated_at",                                                         :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.decimal  "amount_paid",        :precision => 13, :scale => 4, :default => 0.0, :null => false
    t.integer  "invoices_paid",                                     :default => 0,   :null => false
    t.integer  "last_closing_id"
  end

  add_index "cash_desk_closings", ["company_id"], :name => "index_cash_desk_closings_on_company_id"
  add_index "cash_desk_closings", ["created_at"], :name => "index_cash_desk_closings_on_created_at"
  add_index "cash_desk_closings", ["created_by"], :name => "index_cash_desk_closings_on_created_by"
  add_index "cash_desk_closings", ["last_closing_id"], :name => "index_cash_desk_closings_on_last_closing_id"
  add_index "cash_desk_closings", ["office_id"], :name => "index_cash_desk_closings_on_office_id"
  add_index "cash_desk_closings", ["organization_id"], :name => "index_cash_desk_closings_on_organization_id"
  add_index "cash_desk_closings", ["project_id"], :name => "index_cash_desk_closings_on_project_id"

  create_table "centers", :force => true do |t|
    t.integer  "town_id"
    t.string   "name"
    t.boolean  "active"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.string   "code"
  end

  add_index "centers", ["code"], :name => "index_centers_on_code"
  add_index "centers", ["town_id", "code"], :name => "index_centers_on_town_and_code", :unique => true
  add_index "centers", ["town_id"], :name => "index_centers_on_town_id"

  create_table "charge_account_ledger_accounts", :force => true do |t|
    t.integer  "charge_account_id"
    t.integer  "ledger_account_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.integer  "company_id"
  end

  add_index "charge_account_ledger_accounts", ["charge_account_id", "ledger_account_id"], :name => "index_charge_account_ledger_accounts_unique", :unique => true
  add_index "charge_account_ledger_accounts", ["charge_account_id"], :name => "index_charge_account_ledger_accounts_on_charge_account_id"
  add_index "charge_account_ledger_accounts", ["company_id"], :name => "index_charge_account_ledger_accounts_on_company_id"
  add_index "charge_account_ledger_accounts", ["ledger_account_id"], :name => "index_charge_account_ledger_accounts_on_ledger_account_id"

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

  create_table "charge_group_ledger_accounts", :force => true do |t|
    t.integer  "charge_group_id"
    t.integer  "ledger_account_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "charge_group_ledger_accounts", ["charge_group_id"], :name => "index_charge_group_ledger_accounts_on_charge_group_id"
  add_index "charge_group_ledger_accounts", ["ledger_account_id"], :name => "index_charge_group_ledger_accounts_on_ledger_account_id"

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

  create_table "client_bank_accounts", :force => true do |t|
    t.integer  "client_id"
    t.integer  "subscriber_id"
    t.integer  "bank_account_class_id"
    t.integer  "country_id"
    t.string   "iban_dc"
    t.integer  "bank_id"
    t.integer  "bank_office_id"
    t.string   "ccc_dc"
    t.string   "account_no"
    t.string   "holder_fiscal_id"
    t.string   "holder_name"
    t.date     "starting_at"
    t.date     "ending_at"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "client_bank_accounts", ["account_no"], :name => "index_client_bank_accounts_on_account_no"
  add_index "client_bank_accounts", ["bank_account_class_id"], :name => "index_client_bank_accounts_on_bank_account_class_id"
  add_index "client_bank_accounts", ["bank_id"], :name => "index_client_bank_accounts_on_bank_id"
  add_index "client_bank_accounts", ["bank_office_id"], :name => "index_client_bank_accounts_on_bank_office_id"
  add_index "client_bank_accounts", ["client_id", "subscriber_id", "bank_account_class_id", "country_id", "iban_dc", "bank_id", "bank_office_id", "ccc_dc", "account_no"], :name => "index_client_bank_accounts_on_client_and_class_and_no", :unique => true
  add_index "client_bank_accounts", ["client_id"], :name => "index_client_bank_accounts_on_client_id"
  add_index "client_bank_accounts", ["country_id"], :name => "index_client_bank_accounts_on_country_id"
  add_index "client_bank_accounts", ["holder_fiscal_id"], :name => "index_client_bank_accounts_on_holder_fiscal_id"
  add_index "client_bank_accounts", ["holder_name"], :name => "index_client_bank_accounts_on_holder_name"
  add_index "client_bank_accounts", ["subscriber_id"], :name => "index_client_bank_accounts_on_subscriber_id"

  create_table "client_ledger_accounts", :force => true do |t|
    t.integer  "client_id"
    t.integer  "ledger_account_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.integer  "company_id"
  end

  add_index "client_ledger_accounts", ["client_id", "ledger_account_id"], :name => "index_client_ledger_accounts_unique", :unique => true
  add_index "client_ledger_accounts", ["client_id"], :name => "index_client_ledger_accounts_on_client_id"
  add_index "client_ledger_accounts", ["company_id"], :name => "index_client_ledger_accounts_on_company_id"
  add_index "client_ledger_accounts", ["ledger_account_id"], :name => "index_client_ledger_accounts_on_ledger_account_id"

  create_table "client_payments", :force => true do |t|
    t.string   "receipt_no"
    t.integer  "payment_type"
    t.integer  "bill_id"
    t.integer  "invoice_id"
    t.integer  "payment_method_id"
    t.integer  "client_id"
    t.integer  "subscriber_id"
    t.date     "payment_date"
    t.datetime "confirmation_date"
    t.decimal  "amount",                 :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.integer  "instalment_id"
    t.decimal  "surcharge",              :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.integer  "client_bank_account_id"
    t.integer  "charge_account_id"
    t.datetime "created_at",                                                             :null => false
    t.datetime "updated_at",                                                             :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "client_payments", ["bill_id"], :name => "index_client_payments_on_bill_id"
  add_index "client_payments", ["charge_account_id"], :name => "index_client_payments_on_charge_account_id"
  add_index "client_payments", ["client_bank_account_id"], :name => "index_client_payments_on_client_bank_account_id"
  add_index "client_payments", ["client_id"], :name => "index_client_payments_on_client_id"
  add_index "client_payments", ["confirmation_date"], :name => "index_client_payments_on_confirmation_date"
  add_index "client_payments", ["instalment_id"], :name => "index_client_payments_on_instalment_id"
  add_index "client_payments", ["invoice_id"], :name => "index_client_payments_on_invoice_id"
  add_index "client_payments", ["payment_date"], :name => "index_client_payments_on_payment_date"
  add_index "client_payments", ["payment_method_id"], :name => "index_client_payments_on_payment_method_id"
  add_index "client_payments", ["payment_type"], :name => "index_client_payments_on_payment_type"
  add_index "client_payments", ["receipt_no"], :name => "index_client_payments_on_receipt_no"
  add_index "client_payments", ["subscriber_id"], :name => "index_client_payments_on_subscriber_id"

  create_table "clients", :force => true do |t|
    t.integer  "entity_id"
    t.string   "client_code"
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
    t.string   "first_name"
    t.string   "last_name"
    t.string   "company"
  end

  add_index "clients", ["client_code"], :name => "index_clients_on_client_code"
  add_index "clients", ["company"], :name => "index_clients_on_company"
  add_index "clients", ["country_id"], :name => "index_clients_on_country_id"
  add_index "clients", ["entity_id"], :name => "index_clients_on_entity_id"
  add_index "clients", ["first_name"], :name => "index_clients_on_first_name"
  add_index "clients", ["fiscal_id"], :name => "index_clients_on_fiscal_id"
  add_index "clients", ["last_name"], :name => "index_clients_on_last_name"
  add_index "clients", ["ledger_account_id"], :name => "index_clients_on_ledger_account_id"
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
    t.datetime "created_at",                                                                :null => false
    t.datetime "updated_at",                                                                :null => false
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
    t.decimal  "max_order_total",           :precision => 13, :scale => 4, :default => 0.0, :null => false
    t.decimal  "max_order_price",           :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.string   "website"
    t.decimal  "overtime_pct",              :precision => 6,  :scale => 2, :default => 0.0, :null => false
    t.string   "commercial_bill_code"
    t.string   "void_invoice_code"
    t.string   "void_commercial_bill_code"
    t.string   "ledger_account_app_code"
    t.string   "r_last_name"
    t.string   "r_first_name"
    t.string   "r_fiscal_id"
  end

  add_index "companies", ["commercial_bill_code"], :name => "index_companies_on_commercial_bill_code"
  add_index "companies", ["fiscal_id"], :name => "index_companies_on_fiscal_id"
  add_index "companies", ["invoice_code"], :name => "index_companies_on_invoice_code"
  add_index "companies", ["ledger_account_app_code"], :name => "index_companies_on_ledger_account_app_code"
  add_index "companies", ["organization_id", "fiscal_id"], :name => "index_companies_on_organization_id_and_fiscal_id", :unique => true
  add_index "companies", ["organization_id"], :name => "index_companies_on_organization_id"
  add_index "companies", ["province_id"], :name => "index_companies_on_province_id"
  add_index "companies", ["street_type_id"], :name => "index_companies_on_street_type_id"
  add_index "companies", ["town_id"], :name => "index_companies_on_town_id"
  add_index "companies", ["void_commercial_bill_code"], :name => "index_companies_on_void_commercial_bill_code"
  add_index "companies", ["void_invoice_code"], :name => "index_companies_on_void_invoice_code"
  add_index "companies", ["zipcode_id"], :name => "index_companies_on_zipcode_id"

  create_table "company_bank_accounts", :force => true do |t|
    t.integer  "company_id"
    t.integer  "bank_account_class_id"
    t.integer  "country_id"
    t.string   "iban_dc"
    t.integer  "bank_id"
    t.integer  "bank_office_id"
    t.string   "ccc_dc"
    t.string   "account_no"
    t.string   "holder_fiscal_id"
    t.string   "holder_name"
    t.date     "starting_at"
    t.date     "ending_at"
    t.string   "bank_suffix"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
  end

  add_index "company_bank_accounts", ["account_no"], :name => "index_company_bank_accounts_on_account_no"
  add_index "company_bank_accounts", ["bank_account_class_id"], :name => "index_company_bank_accounts_on_bank_account_class_id"
  add_index "company_bank_accounts", ["bank_id"], :name => "index_company_bank_accounts_on_bank_id"
  add_index "company_bank_accounts", ["bank_office_id"], :name => "index_company_bank_accounts_on_bank_office_id"
  add_index "company_bank_accounts", ["bank_suffix"], :name => "index_company_bank_accounts_on_bank_suffix"
  add_index "company_bank_accounts", ["company_id", "bank_account_class_id", "country_id", "iban_dc", "bank_id", "bank_office_id", "ccc_dc", "account_no"], :name => "index_company_bank_accounts_on_company_and_class_and_no", :unique => true
  add_index "company_bank_accounts", ["company_id"], :name => "index_company_bank_accounts_on_company_id"
  add_index "company_bank_accounts", ["country_id"], :name => "index_company_bank_accounts_on_country_id"
  add_index "company_bank_accounts", ["holder_fiscal_id"], :name => "index_company_bank_accounts_on_holder_fiscal_id"
  add_index "company_bank_accounts", ["holder_name"], :name => "index_company_bank_accounts_on_holder_name"

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

  create_table "complaint_classes", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "complaint_classes", ["name"], :name => "index_complaint_classes_on_name"

  create_table "complaint_document_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "complaint_document_types", ["name"], :name => "index_complaint_document_types_on_name"

  create_table "complaint_documents", :force => true do |t|
    t.integer  "complaint_id"
    t.integer  "complaint_document_type_id"
    t.integer  "flow",                       :limit => 1, :default => 1, :null => false
    t.datetime "created_at",                                             :null => false
    t.datetime "updated_at",                                             :null => false
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "complaint_documents", ["complaint_document_type_id"], :name => "index_complaint_documents_on_complaint_document_type_id"
  add_index "complaint_documents", ["complaint_id"], :name => "index_complaint_documents_on_complaint_id"
  add_index "complaint_documents", ["flow"], :name => "index_complaint_documents_on_flow"

  create_table "complaint_statuses", :force => true do |t|
    t.string   "name"
    t.integer  "action",     :limit => 1, :default => 1, :null => false
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "complaint_statuses", ["action"], :name => "index_complaint_statuses_on_action"
  add_index "complaint_statuses", ["name"], :name => "index_complaint_statuses_on_name"

  create_table "complaints", :force => true do |t|
    t.string   "complaint_no"
    t.integer  "complaint_class_id"
    t.integer  "complaint_status_id"
    t.integer  "client_id"
    t.integer  "subscriber_id"
    t.integer  "project_id"
    t.string   "description"
    t.string   "official_sheet"
    t.datetime "starting_at"
    t.datetime "ending_at"
    t.string   "answer",              :limit => 1000
    t.string   "remarks"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "complaints", ["client_id"], :name => "index_complaints_on_client_id"
  add_index "complaints", ["complaint_class_id"], :name => "index_complaints_on_complaint_class_id"
  add_index "complaints", ["complaint_no"], :name => "index_complaints_on_complaint_no"
  add_index "complaints", ["complaint_status_id"], :name => "index_complaints_on_complaint_status_id"
  add_index "complaints", ["official_sheet"], :name => "index_complaints_on_official_sheet"
  add_index "complaints", ["project_id"], :name => "index_complaints_on_project_id"
  add_index "complaints", ["subscriber_id"], :name => "index_complaints_on_subscriber_id"

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

  create_table "contracted_tariffs", :force => true do |t|
    t.integer  "water_supply_contract_id"
    t.integer  "tariff_id"
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.date     "starting_at"
    t.date     "ending_at"
  end

  add_index "contracted_tariffs", ["tariff_id"], :name => "index_contracted_tariffs_on_tariff_id"
  add_index "contracted_tariffs", ["water_supply_contract_id"], :name => "index_contracted_tariffs_on_water_supply_contract_id"

  create_table "contracting_request_document_types", :force => true do |t|
    t.string   "name"
    t.boolean  "required"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  create_table "contracting_request_documents", :force => true do |t|
    t.integer  "contracting_request_id"
    t.integer  "contracting_request_document_type_id"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "contracting_request_documents", ["contracting_request_document_type_id"], :name => "index_contracting_request_document_type"
  add_index "contracting_request_documents", ["contracting_request_id"], :name => "index_contracting_request_documents_on_contracting_request_id"

  create_table "contracting_request_statuses", :force => true do |t|
    t.string   "name"
    t.boolean  "requires_work_order"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  create_table "contracting_request_types", :force => true do |t|
    t.string   "description"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.integer  "formality_id"
  end

  add_index "contracting_request_types", ["formality_id"], :name => "index_contracting_request_types_on_formality_id"

  create_table "contracting_requests", :force => true do |t|
    t.string   "request_no"
    t.integer  "project_id"
    t.date     "request_date"
    t.integer  "entity_id"
    t.integer  "contracting_request_type_id"
    t.integer  "contracting_request_status_id"
    t.string   "r_last_name"
    t.string   "r_first_name"
    t.string   "r_fiscal_id"
    t.integer  "entity_street_directory_id"
    t.integer  "entity_street_type_id"
    t.string   "entity_fiscal_id"
    t.string   "entity_street_name"
    t.string   "entity_street_number"
    t.string   "entity_building"
    t.string   "entity_floor"
    t.string   "entity_floor_office"
    t.integer  "entity_zipcode_id"
    t.integer  "entity_town_id"
    t.integer  "entity_province_id"
    t.integer  "entity_region_id"
    t.integer  "entity_country_id"
    t.string   "entity_phone"
    t.string   "entity_fax"
    t.string   "entity_cellular"
    t.string   "entity_email"
    t.string   "client_last_name"
    t.string   "client_first_name"
    t.string   "client_company"
    t.integer  "client_street_directory_id"
    t.integer  "client_street_type_id"
    t.string   "client_street_name"
    t.string   "client_street_number"
    t.string   "client_building"
    t.string   "client_floor"
    t.string   "client_floor_office"
    t.integer  "client_zipcode_id"
    t.integer  "client_town_id"
    t.integer  "client_province_id"
    t.integer  "client_region_id"
    t.integer  "client_country_id"
    t.string   "client_phone"
    t.string   "client_fax"
    t.string   "client_cellular"
    t.string   "client_email"
    t.string   "subscriber_last_name"
    t.string   "subscriber_first_name"
    t.string   "subscriber_company"
    t.integer  "subscriber_street_directory_id"
    t.integer  "subscriber_street_type_id"
    t.string   "subscriber_street_name"
    t.string   "subscriber_street_number"
    t.string   "subscriber_building"
    t.string   "subscriber_floor"
    t.string   "subscriber_floor_office"
    t.integer  "subscriber_zipcode_id"
    t.integer  "subscriber_town_id"
    t.integer  "subscriber_province_id"
    t.integer  "subscriber_region_id"
    t.integer  "subscriber_country_id"
    t.integer  "subscriber_center_id"
    t.string   "subscriber_phone"
    t.string   "subscriber_fax"
    t.string   "subscriber_cellular"
    t.string   "subscriber_email"
    t.integer  "country_id"
    t.string   "iban_dc"
    t.integer  "bank_id"
    t.integer  "bank_office_id"
    t.string   "ccc_dc"
    t.string   "account_no"
    t.integer  "work_order_id"
    t.integer  "subscriber_id"
    t.integer  "service_point_id"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "contracting_requests", ["bank_id"], :name => "index_contracting_requests_on_bank_id"
  add_index "contracting_requests", ["bank_office_id"], :name => "index_contracting_requests_on_bank_office_id"
  add_index "contracting_requests", ["client_country_id"], :name => "index_contracting_requests_on_client_country_id"
  add_index "contracting_requests", ["client_province_id"], :name => "index_contracting_requests_on_client_province_id"
  add_index "contracting_requests", ["client_region_id"], :name => "index_contracting_requests_on_client_region_id"
  add_index "contracting_requests", ["client_street_directory_id"], :name => "index_contracting_requests_on_client_street_directory_id"
  add_index "contracting_requests", ["client_street_type_id"], :name => "index_contracting_requests_on_client_street_type_id"
  add_index "contracting_requests", ["client_town_id"], :name => "index_contracting_requests_on_client_town_id"
  add_index "contracting_requests", ["client_zipcode_id"], :name => "index_contracting_requests_on_client_zipcode_id"
  add_index "contracting_requests", ["contracting_request_status_id"], :name => "index_contracting_requests_on_contracting_request_status_id"
  add_index "contracting_requests", ["contracting_request_type_id"], :name => "index_contracting_requests_on_contracting_request_type_id"
  add_index "contracting_requests", ["country_id"], :name => "index_contracting_requests_on_country_id"
  add_index "contracting_requests", ["entity_country_id"], :name => "index_contracting_requests_on_entity_country_id"
  add_index "contracting_requests", ["entity_id"], :name => "index_contracting_requests_on_entity_id"
  add_index "contracting_requests", ["entity_province_id"], :name => "index_contracting_requests_on_entity_province_id"
  add_index "contracting_requests", ["entity_region_id"], :name => "index_contracting_requests_on_entity_region_id"
  add_index "contracting_requests", ["entity_street_directory_id"], :name => "index_contracting_requests_on_entity_street_directory_id"
  add_index "contracting_requests", ["entity_street_type_id"], :name => "index_contracting_requests_on_entity_street_type_id"
  add_index "contracting_requests", ["entity_town_id"], :name => "index_contracting_requests_on_entity_town_id"
  add_index "contracting_requests", ["entity_zipcode_id"], :name => "index_contracting_requests_on_entity_zipcode_id"
  add_index "contracting_requests", ["project_id"], :name => "index_contracting_requests_on_project_id"
  add_index "contracting_requests", ["r_fiscal_id"], :name => "index_contracting_requests_on_r_fiscal_id"
  add_index "contracting_requests", ["service_point_id"], :name => "index_contracting_requests_on_service_point_id"
  add_index "contracting_requests", ["subscriber_center_id"], :name => "index_contracting_requests_on_subscriber_center_id"
  add_index "contracting_requests", ["subscriber_country_id"], :name => "index_contracting_requests_on_subscriber_country_id"
  add_index "contracting_requests", ["subscriber_id"], :name => "index_contracting_requests_on_subscriber_id"
  add_index "contracting_requests", ["subscriber_province_id"], :name => "index_contracting_requests_on_subscriber_province_id"
  add_index "contracting_requests", ["subscriber_region_id"], :name => "index_contracting_requests_on_subscriber_region_id"
  add_index "contracting_requests", ["subscriber_street_directory_id"], :name => "index_contracting_requests_on_subscriber_street_directory_id"
  add_index "contracting_requests", ["subscriber_street_type_id"], :name => "index_contracting_requests_on_subscriber_street_type_id"
  add_index "contracting_requests", ["subscriber_town_id"], :name => "index_contracting_requests_on_subscriber_town_id"
  add_index "contracting_requests", ["subscriber_zipcode_id"], :name => "index_contracting_requests_on_subscriber_zipcode_id"
  add_index "contracting_requests", ["work_order_id"], :name => "index_contracting_requests_on_work_order_id"

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
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.string   "code"
    t.integer  "prefix",      :limit => 2, :default => 0, :null => false
    t.integer  "currency_id"
  end

  add_index "countries", ["code"], :name => "index_countries_on_code"
  add_index "countries", ["currency_id"], :name => "index_countries_on_currency_id"

  create_table "currencies", :force => true do |t|
    t.string   "currency"
    t.string   "alphabetic_code", :limit => 3
    t.integer  "numeric_code",    :limit => 2
    t.integer  "minor_unit",      :limit => 1, :default => 0, :null => false
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "currencies", ["alphabetic_code"], :name => "index_currencies_on_alphabetic_code"
  add_index "currencies", ["currency"], :name => "index_currencies_on_currency"
  add_index "currencies", ["numeric_code"], :name => "index_currencies_on_numeric_code"

  create_table "currency_instruments", :force => true do |t|
    t.integer  "currency_id"
    t.integer  "type_i",      :limit => 1,                                :default => 1,   :null => false
    t.decimal  "value_i",                  :precision => 14, :scale => 6, :default => 0.0, :null => false
    t.datetime "created_at",                                                               :null => false
    t.datetime "updated_at",                                                               :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "currency_instruments", ["currency_id"], :name => "index_currency_instruments_on_currency_id"
  add_index "currency_instruments", ["type_i"], :name => "index_currency_instruments_on_type_i"

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

  create_table "debt_claim_items", :force => true do |t|
    t.integer  "debt_claim_id"
    t.integer  "bill_id"
    t.integer  "invoice_id"
    t.integer  "debt_claim_status_id"
    t.date     "payday_limit"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "debt_claim_items", ["bill_id"], :name => "index_debt_claim_items_on_bill_id"
  add_index "debt_claim_items", ["debt_claim_id"], :name => "index_debt_claim_items_on_debt_claim_id"
  add_index "debt_claim_items", ["debt_claim_status_id"], :name => "index_debt_claim_items_on_debt_claim_status_id"
  add_index "debt_claim_items", ["invoice_id"], :name => "index_debt_claim_items_on_invoice_id"

  create_table "debt_claim_phases", :force => true do |t|
    t.string   "name"
    t.decimal  "surcharge_pct", :precision => 6, :scale => 2, :default => 0.0, :null => false
    t.datetime "created_at",                                                   :null => false
    t.datetime "updated_at",                                                   :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "debt_claim_phases", ["name"], :name => "index_debt_claim_phases_on_name"

  create_table "debt_claim_statuses", :force => true do |t|
    t.string   "name"
    t.integer  "action",     :limit => 1, :default => 1, :null => false
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "debt_claim_statuses", ["action"], :name => "index_debt_claim_statuses_on_action"
  add_index "debt_claim_statuses", ["name"], :name => "index_debt_claim_statuses_on_name"

  create_table "debt_claims", :force => true do |t|
    t.integer  "project_id"
    t.string   "claim_no"
    t.integer  "debt_claim_phase_id"
    t.date     "closed_at"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "debt_claims", ["claim_no"], :name => "index_debt_claims_on_claim_no"
  add_index "debt_claims", ["debt_claim_phase_id"], :name => "index_debt_claims_on_debt_claim_phase_id"
  add_index "debt_claims", ["project_id"], :name => "index_debt_claims_on_project_id"

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
    t.decimal  "totals",            :precision => 13, :scale => 4, :default => 0.0, :null => false
    t.decimal  "total_costs",       :precision => 13, :scale => 4, :default => 0.0, :null => false
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
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.string   "created_by"
    t.string   "updated_by"
    t.integer  "organization_id"
    t.boolean  "is_foreign",       :default => false, :null => false
    t.integer  "country_of_birth"
  end

  add_index "entities", ["cellular"], :name => "index_entities_on_cellular"
  add_index "entities", ["company"], :name => "index_entities_on_company"
  add_index "entities", ["country_id"], :name => "index_entities_on_country_id"
  add_index "entities", ["country_of_birth"], :name => "index_entities_on_country_of_birth"
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

  create_table "formalities", :force => true do |t|
    t.integer  "formality_type_id"
    t.string   "code"
    t.string   "name"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "formalities", ["code"], :name => "index_formalities_on_code"
  add_index "formalities", ["formality_type_id"], :name => "index_formalities_on_formality_type_id"
  add_index "formalities", ["name"], :name => "index_formalities_on_name"

  create_table "formality_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "formality_types", ["name"], :name => "index_formality_types_on_name"

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

  create_table "infrastructure_types", :force => true do |t|
    t.string   "name"
    t.integer  "organization_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "infrastructure_types", ["organization_id"], :name => "index_infrastructure_types_on_organization_id"

  create_table "infrastructures", :force => true do |t|
    t.string   "name"
    t.integer  "infrastructure_type_id"
    t.integer  "organization_id"
    t.integer  "company_id"
    t.integer  "office_id"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.string   "code"
  end

  add_index "infrastructures", ["code"], :name => "index_infrastructures_on_code"
  add_index "infrastructures", ["company_id"], :name => "index_infrastructures_on_company_id"
  add_index "infrastructures", ["infrastructure_type_id"], :name => "index_infrastructures_on_infrastructure_type_id"
  add_index "infrastructures", ["office_id"], :name => "index_infrastructures_on_office_id"
  add_index "infrastructures", ["organization_id", "code"], :name => "index_infraestructure_unique", :unique => true
  add_index "infrastructures", ["organization_id"], :name => "index_infrastructures_on_organization_id"

  create_table "instalment_invoices", :force => true do |t|
    t.integer  "instalment_id"
    t.integer  "bill_id"
    t.integer  "invoice_id"
    t.decimal  "debt",          :precision => 13, :scale => 4, :default => 0.0, :null => false
    t.decimal  "amount",        :precision => 13, :scale => 4, :default => 0.0, :null => false
    t.datetime "created_at",                                                    :null => false
    t.datetime "updated_at",                                                    :null => false
  end

  add_index "instalment_invoices", ["bill_id"], :name => "index_instalment_invoices_on_bill_id"
  add_index "instalment_invoices", ["instalment_id"], :name => "index_instalment_invoices_on_instalment_id"
  add_index "instalment_invoices", ["invoice_id"], :name => "index_instalment_invoices_on_invoice_id"

  create_table "instalment_plans", :force => true do |t|
    t.string   "instalment_no"
    t.date     "instalment_date"
    t.integer  "payment_method_id"
    t.integer  "client_id"
    t.integer  "subscriber_id"
    t.decimal  "surcharge_pct",     :precision => 6, :scale => 2, :default => 0.0, :null => false
    t.datetime "created_at",                                                       :null => false
    t.datetime "updated_at",                                                       :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.integer  "organization_id"
  end

  add_index "instalment_plans", ["client_id"], :name => "index_instalment_plans_on_client_id"
  add_index "instalment_plans", ["instalment_date"], :name => "index_instalment_plans_on_instalment_date"
  add_index "instalment_plans", ["instalment_no"], :name => "index_instalment_plans_on_instalment_no"
  add_index "instalment_plans", ["organization_id"], :name => "index_instalment_plans_on_organization_id"
  add_index "instalment_plans", ["payment_method_id"], :name => "index_instalment_plans_on_payment_method_id"
  add_index "instalment_plans", ["subscriber_id"], :name => "index_instalment_plans_on_subscriber_id"

  create_table "instalments", :force => true do |t|
    t.integer  "instalment_plan_id"
    t.integer  "bill_id"
    t.integer  "invoice_id"
    t.integer  "instalment"
    t.date     "payday_limit"
    t.decimal  "amount",             :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.decimal  "surcharge",          :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.datetime "created_at",                                                         :null => false
    t.datetime "updated_at",                                                         :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "instalments", ["bill_id"], :name => "index_instalments_on_bill_id"
  add_index "instalments", ["instalment_plan_id"], :name => "index_instalments_on_instalment_plan_id"
  add_index "instalments", ["invoice_id"], :name => "index_instalments_on_invoice_id"
  add_index "instalments", ["payday_limit"], :name => "index_instalments_on_payday_limit"

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
    t.decimal  "price",              :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.decimal  "average_price",      :precision => 12, :scale => 4, :default => 0.0, :null => false
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
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.integer  "approver_id"
    t.datetime "approval_date"
    t.boolean  "quick",                   :default => false
  end

  add_index "inventory_counts", ["approver_id"], :name => "index_inventory_counts_on_approver_id"
  add_index "inventory_counts", ["count_date"], :name => "index_inventory_counts_on_count_date"
  add_index "inventory_counts", ["count_no"], :name => "index_inventory_counts_on_count_no"
  add_index "inventory_counts", ["inventory_count_type_id"], :name => "index_inventory_counts_on_inventory_count_type_id"
  add_index "inventory_counts", ["organization_id", "count_no"], :name => "index_inventory_counts_on_organization_id_and_count_no", :unique => true
  add_index "inventory_counts", ["organization_id"], :name => "index_inventory_counts_on_organization_id"
  add_index "inventory_counts", ["product_family_id"], :name => "index_inventory_counts_on_product_family_id"
  add_index "inventory_counts", ["store_id"], :name => "index_inventory_counts_on_store_id"

  create_table "inventory_movements", :force => true do |t|
    t.integer  "store_id"
    t.integer  "product_id"
    t.string   "type"
    t.datetime "mdate"
    t.integer  "parent_id"
    t.integer  "item_id"
    t.decimal  "quantity",   :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.decimal  "price",      :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.datetime "created_at",                                                 :null => false
    t.datetime "updated_at",                                                 :null => false
    t.date     "ddate"
    t.datetime "adate"
  end

  add_index "inventory_movements", ["adate"], :name => "index_inventory_movements_on_adate"
  add_index "inventory_movements", ["ddate"], :name => "index_inventory_movements_on_ddate"
  add_index "inventory_movements", ["mdate"], :name => "index_inventory_movements_on_mdate"
  add_index "inventory_movements", ["product_id"], :name => "index_inventory_movements_on_product_id"
  add_index "inventory_movements", ["store_id", "product_id", "type", "parent_id", "item_id"], :name => "index_inventory_movements_unique", :unique => true
  add_index "inventory_movements", ["store_id"], :name => "index_inventory_movements_on_store_id"

  create_table "inventory_transfer_items", :force => true do |t|
    t.integer  "inventory_transfer_id"
    t.integer  "product_id"
    t.decimal  "quantity",              :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.decimal  "decimal",               :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.decimal  "outbound_current",      :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.decimal  "inbound_current",       :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.decimal  "price",                 :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.decimal  "average_price",         :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.datetime "created_at",                                                            :null => false
    t.datetime "updated_at",                                                            :null => false
  end

  add_index "inventory_transfer_items", ["inventory_transfer_id"], :name => "index_inventory_transfer_items_on_inventory_transfer_id"
  add_index "inventory_transfer_items", ["product_id"], :name => "index_inventory_transfer_items_on_product_id"

  create_table "inventory_transfers", :force => true do |t|
    t.string   "transfer_no"
    t.date     "transfer_date"
    t.integer  "organization_id"
    t.integer  "company_id"
    t.integer  "outbound_store_id"
    t.integer  "inbound_store_id"
    t.integer  "approver_id"
    t.datetime "approval_date"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "inventory_transfers", ["approver_id"], :name => "index_inventory_transfers_on_approver_id"
  add_index "inventory_transfers", ["company_id"], :name => "index_inventory_transfers_on_company_id"
  add_index "inventory_transfers", ["inbound_store_id"], :name => "index_inventory_transfers_on_inbound_store_id"
  add_index "inventory_transfers", ["organization_id", "transfer_no"], :name => "index_inventory_transfers_on_organization_id_and_transfer_no", :unique => true
  add_index "inventory_transfers", ["organization_id"], :name => "index_inventory_transfers_on_organization_id"
  add_index "inventory_transfers", ["outbound_store_id"], :name => "index_inventory_transfers_on_outbound_store_id"
  add_index "inventory_transfers", ["transfer_date"], :name => "index_inventory_transfers_on_transfer_date"
  add_index "inventory_transfers", ["transfer_no"], :name => "index_inventory_transfers_on_transfer_no"

  create_table "invoice_bills", :id => false, :force => true do |t|
    t.integer "invoice_id",                                        :default => 0, :null => false
    t.integer "organization_id"
    t.integer "project_id"
    t.integer "client_id"
    t.integer "subscriber_id"
    t.integer "billing_period_id"
    t.string  "invoice_no"
    t.date    "invoice_date"
    t.integer "invoice_type_id"
    t.decimal "subtotal",          :precision => 47, :scale => 10
    t.decimal "taxes",             :precision => 65, :scale => 22
    t.decimal "bonus",             :precision => 57, :scale => 16
    t.decimal "taxable",           :precision => 58, :scale => 16
    t.decimal "total",             :precision => 65, :scale => 22
  end

  create_table "invoice_credits", :id => false, :force => true do |t|
    t.integer "invoice_id",                                          :default => 0, :null => false
    t.integer "organization_id"
    t.integer "project_id"
    t.integer "client_id"
    t.integer "subscriber_id"
    t.integer "billing_period_id"
    t.string  "invoice_no"
    t.date    "invoice_date"
    t.integer "invoice_type_id"
    t.decimal "subtotal",            :precision => 47, :scale => 10
    t.decimal "taxes",               :precision => 65, :scale => 22
    t.decimal "bonus",               :precision => 57, :scale => 16
    t.decimal "taxable",             :precision => 58, :scale => 16
    t.decimal "total",               :precision => 65, :scale => 22
    t.integer "original_invoice_id"
  end

  create_table "invoice_debts", :id => false, :force => true do |t|
    t.integer "invoice_id",                                      :default => 0, :null => false
    t.integer "organization_id"
    t.integer "client_id"
    t.integer "subscriber_id"
    t.string  "invoice_no"
    t.decimal "subtotal",        :precision => 47, :scale => 10
    t.decimal "taxes",           :precision => 65, :scale => 22
    t.decimal "bonus",           :precision => 57, :scale => 16
    t.decimal "taxable",         :precision => 58, :scale => 16
    t.decimal "total",           :precision => 65, :scale => 22
    t.decimal "paid",            :precision => 34, :scale => 4
    t.decimal "debt",            :precision => 65, :scale => 22
  end

  create_table "invoice_items", :force => true do |t|
    t.integer  "invoice_id"
    t.integer  "tariff_id"
    t.integer  "product_id"
    t.string   "code"
    t.string   "subcode"
    t.string   "description"
    t.integer  "measure_id"
    t.decimal  "quantity",           :precision => 12, :scale => 4, :default => 1.0, :null => false
    t.decimal  "price",              :precision => 12, :scale => 6, :default => 0.0, :null => false
    t.decimal  "discount_pct",       :precision => 6,  :scale => 2, :default => 0.0, :null => false
    t.decimal  "discount",           :precision => 12, :scale => 6, :default => 0.0, :null => false
    t.integer  "tax_type_id"
    t.datetime "created_at",                                                         :null => false
    t.datetime "updated_at",                                                         :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.integer  "sale_offer_id"
    t.integer  "sale_offer_item_id"
  end

  add_index "invoice_items", ["invoice_id"], :name => "index_invoice_items_on_invoice_id"
  add_index "invoice_items", ["measure_id"], :name => "index_invoice_items_on_measure_id"
  add_index "invoice_items", ["product_id"], :name => "index_invoice_items_on_product_id"
  add_index "invoice_items", ["sale_offer_id"], :name => "index_invoice_items_on_sale_offer_id"
  add_index "invoice_items", ["sale_offer_item_id"], :name => "index_invoice_items_on_sale_offer_item_id"
  add_index "invoice_items", ["tariff_id"], :name => "index_invoice_items_on_tariff_id"
  add_index "invoice_items", ["tax_type_id"], :name => "index_invoice_items_on_tax_type_id"

  create_table "invoice_operations", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  create_table "invoice_payments", :id => false, :force => true do |t|
    t.integer "invoice_id"
    t.decimal "paid",       :precision => 34, :scale => 4
  end

  create_table "invoice_rebills", :id => false, :force => true do |t|
    t.integer "invoice_id",                                          :default => 0, :null => false
    t.integer "organization_id"
    t.integer "project_id"
    t.integer "client_id"
    t.integer "subscriber_id"
    t.integer "billing_period_id"
    t.string  "invoice_no"
    t.date    "invoice_date"
    t.integer "invoice_type_id"
    t.decimal "subtotal",            :precision => 47, :scale => 10
    t.decimal "taxes",               :precision => 65, :scale => 22
    t.decimal "bonus",               :precision => 57, :scale => 16
    t.decimal "taxable",             :precision => 58, :scale => 16
    t.decimal "total",               :precision => 65, :scale => 22
    t.integer "original_invoice_id"
  end

  create_table "invoice_statuses", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  create_table "invoice_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  create_table "invoices", :force => true do |t|
    t.string   "invoice_no"
    t.date     "invoice_date"
    t.integer  "bill_id"
    t.integer  "invoice_type_id"
    t.integer  "invoice_operation_id"
    t.integer  "invoice_status_id"
    t.integer  "billing_period_id"
    t.integer  "consumption"
    t.integer  "consumption_real"
    t.integer  "consumption_estimated"
    t.integer  "consumption_other"
    t.integer  "tariff_scheme_id"
    t.integer  "biller_id"
    t.decimal  "discount_pct",          :precision => 6,  :scale => 2, :default => 0.0, :null => false
    t.decimal  "exemption",             :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.integer  "original_invoice_id"
    t.integer  "charge_account_id"
    t.datetime "created_at",                                                            :null => false
    t.datetime "updated_at",                                                            :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.date     "payday_limit"
    t.datetime "reading_1_date"
    t.datetime "reading_2_date"
    t.integer  "reading_1_index"
    t.integer  "reading_2_index"
    t.string   "remarks"
    t.integer  "organization_id"
    t.integer  "payment_method_id"
    t.integer  "sale_offer_id"
    t.decimal  "totals",                :precision => 13, :scale => 4, :default => 0.0, :null => false
    t.decimal  "receivables",           :precision => 13, :scale => 4, :default => 0.0, :null => false
  end

  add_index "invoices", ["bill_id"], :name => "index_invoices_on_bill_id"
  add_index "invoices", ["biller_id"], :name => "index_invoices_on_biller_id"
  add_index "invoices", ["billing_period_id"], :name => "index_invoices_on_billing_period_id"
  add_index "invoices", ["charge_account_id"], :name => "index_invoices_on_charge_account_id"
  add_index "invoices", ["invoice_date"], :name => "index_invoices_on_invoice_date"
  add_index "invoices", ["invoice_no"], :name => "index_invoices_on_invoice_no"
  add_index "invoices", ["invoice_operation_id"], :name => "index_invoices_on_invoice_operation_id"
  add_index "invoices", ["invoice_status_id"], :name => "index_invoices_on_invoice_status_id"
  add_index "invoices", ["invoice_type_id"], :name => "index_invoices_on_invoice_type_id"
  add_index "invoices", ["organization_id"], :name => "index_invoices_on_organization_id"
  add_index "invoices", ["original_invoice_id"], :name => "index_invoices_on_original_invoice_id"
  add_index "invoices", ["payment_method_id"], :name => "index_invoices_on_payment_method_id"
  add_index "invoices", ["sale_offer_id"], :name => "index_invoices_on_sale_offer_id"
  add_index "invoices", ["tariff_scheme_id"], :name => "index_invoices_on_tariff_scheme_id"

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
    t.integer  "company_id"
  end

  add_index "ledger_accounts", ["accounting_group_id"], :name => "index_ledger_accounts_on_accounting_group_id"
  add_index "ledger_accounts", ["code"], :name => "index_ledger_accounts_on_code"
  add_index "ledger_accounts", ["company_id"], :name => "index_ledger_accounts_on_company_id"
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

  create_table "meter_brands", :force => true do |t|
    t.integer  "manufacturer_id"
    t.string   "brand"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.string   "letter_id",       :limit => 1
  end

  add_index "meter_brands", ["brand"], :name => "index_meter_brands_on_brand"
  add_index "meter_brands", ["manufacturer_id"], :name => "index_meter_brands_on_manufacturer_id"

  create_table "meter_details", :force => true do |t|
    t.integer  "meter_id"
    t.integer  "subscriber_id"
    t.date     "installation_date"
    t.integer  "installation_reading"
    t.integer  "meter_location_id"
    t.date     "withdrawal_date"
    t.integer  "withdrawal_reading"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "meter_details", ["installation_date"], :name => "index_meter_details_on_installation_date"
  add_index "meter_details", ["meter_id"], :name => "index_meter_details_on_meter_id"
  add_index "meter_details", ["meter_location_id"], :name => "index_meter_details_on_meter_location_id"
  add_index "meter_details", ["subscriber_id"], :name => "index_meter_details_on_subscriber_id"
  add_index "meter_details", ["withdrawal_date"], :name => "index_meter_details_on_withdrawal_date"

  create_table "meter_locations", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "meter_locations", ["name"], :name => "index_meter_locations_on_name"

  create_table "meter_models", :force => true do |t|
    t.string   "model"
    t.integer  "meter_type_id"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.integer  "digits",         :limit => 1, :default => 0, :null => false
    t.integer  "dials",          :limit => 1, :default => 1, :null => false
    t.integer  "meter_brand_id"
    t.string   "letter_id",      :limit => 1
  end

  add_index "meter_models", ["meter_brand_id"], :name => "index_meter_models_on_meter_brand_id"
  add_index "meter_models", ["meter_type_id"], :name => "index_meter_models_on_meter_type_id"
  add_index "meter_models", ["model"], :name => "index_meter_models_on_model"

  create_table "meter_owners", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "meter_owners", ["name"], :name => "index_meter_owners_on_name"

  create_table "meter_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "meter_types", ["name"], :name => "index_meter_types_on_name"

  create_table "meters", :force => true do |t|
    t.string   "meter_code"
    t.integer  "meter_model_id"
    t.integer  "caliber_id"
    t.integer  "meter_owner_id"
    t.date     "manufacturing_date"
    t.integer  "manufacturing_year",      :limit => 2, :default => 0, :null => false
    t.date     "expiry_date"
    t.date     "purchase_date"
    t.date     "first_installation_date"
    t.date     "last_withdrawal_date"
    t.integer  "organization_id"
    t.datetime "created_at",                                          :null => false
    t.datetime "updated_at",                                          :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.integer  "company_id"
    t.integer  "office_id"
  end

  add_index "meters", ["caliber_id"], :name => "index_meters_on_caliber_id"
  add_index "meters", ["company_id"], :name => "index_meters_on_company_id"
  add_index "meters", ["manufacturing_year"], :name => "index_meters_on_manufacturing_year"
  add_index "meters", ["meter_code"], :name => "index_meters_on_meter_code"
  add_index "meters", ["meter_model_id"], :name => "index_meters_on_meter_model_id"
  add_index "meters", ["meter_owner_id"], :name => "index_meters_on_meter_owner_id"
  add_index "meters", ["office_id"], :name => "index_meters_on_office_id"
  add_index "meters", ["organization_id"], :name => "index_meters_on_organization_id"

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
    t.decimal  "totals",            :precision => 13, :scale => 4, :default => 0.0, :null => false
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
    t.integer  "purchase_orders_count",                                  :default => 0
    t.decimal  "totals",                  :precision => 13, :scale => 4, :default => 0.0, :null => false
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
    t.integer  "zone_id"
    t.string   "r_last_name"
    t.string   "r_first_name"
    t.string   "r_fiscal_id"
    t.string   "r_position"
  end

  add_index "offices", ["company_id"], :name => "index_offices_on_company_id"
  add_index "offices", ["nomina_id"], :name => "index_offices_on_nomina_id"
  add_index "offices", ["office_code"], :name => "index_offices_on_office_code"
  add_index "offices", ["province_id"], :name => "index_offices_on_province_id"
  add_index "offices", ["street_type_id"], :name => "index_offices_on_street_type_id"
  add_index "offices", ["town_id"], :name => "index_offices_on_town_id"
  add_index "offices", ["zipcode_id"], :name => "index_offices_on_zipcode_id"
  add_index "offices", ["zone_id"], :name => "index_offices_on_zone_id"

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
    t.integer  "expiration_days",                                              :default => 0,     :null => false
    t.decimal  "default_interest",              :precision => 12, :scale => 4, :default => 0.0,   :null => false
    t.datetime "created_at",                                                                      :null => false
    t.datetime "updated_at",                                                                      :null => false
    t.string   "created_by"
    t.string   "updated_by"
    t.integer  "flow",             :limit => 2
    t.integer  "organization_id"
    t.boolean  "cashier",                                                      :default => false, :null => false
  end

  add_index "payment_methods", ["description"], :name => "index_payment_methods_on_description"
  add_index "payment_methods", ["flow"], :name => "index_payment_methods_on_flow"
  add_index "payment_methods", ["organization_id"], :name => "index_payment_methods_on_organization_id"

  create_table "payment_types", :force => true do |t|
    t.string   "name"
    t.integer  "payment_method_id"
    t.integer  "organization_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  add_index "payment_types", ["organization_id"], :name => "index_payment_types_on_organization_id"
  add_index "payment_types", ["payment_method_id"], :name => "index_payment_types_on_payment_method_id"

  create_table "pre_bills", :force => true do |t|
    t.string   "bill_no"
    t.integer  "project_id"
    t.integer  "client_id"
    t.integer  "subscriber_id"
    t.integer  "invoice_status_id"
    t.date     "bill_date"
    t.string   "last_name"
    t.string   "first_name"
    t.string   "company"
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
    t.integer  "bill_id"
    t.datetime "confirmation_date"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.integer  "pre_group_no"
    t.integer  "reading_1_id"
    t.integer  "reading_2_id"
  end

  add_index "pre_bills", ["bill_id"], :name => "index_pre_bills_on_bill_id"
  add_index "pre_bills", ["client_id"], :name => "index_pre_bills_on_client_id"
  add_index "pre_bills", ["country_id"], :name => "index_pre_bills_on_country_id"
  add_index "pre_bills", ["invoice_status_id"], :name => "index_pre_bills_on_invoice_status_id"
  add_index "pre_bills", ["project_id"], :name => "index_pre_bills_on_project_id"
  add_index "pre_bills", ["province_id"], :name => "index_pre_bills_on_province_id"
  add_index "pre_bills", ["region_id"], :name => "index_pre_bills_on_region_id"
  add_index "pre_bills", ["street_type_id"], :name => "index_pre_bills_on_street_type_id"
  add_index "pre_bills", ["subscriber_id"], :name => "index_pre_bills_on_subscriber_id"
  add_index "pre_bills", ["town_id"], :name => "index_pre_bills_on_town_id"
  add_index "pre_bills", ["zipcode_id"], :name => "index_pre_bills_on_zipcode_id"

  create_table "pre_invoice_items", :force => true do |t|
    t.integer  "pre_invoice_id"
    t.integer  "tariff_id"
    t.integer  "product_id"
    t.string   "code"
    t.string   "subcode"
    t.string   "description"
    t.integer  "measure_id"
    t.decimal  "quantity",       :precision => 12, :scale => 4, :default => 1.0, :null => false
    t.decimal  "price",          :precision => 12, :scale => 6, :default => 0.0, :null => false
    t.decimal  "discount_pct",   :precision => 6,  :scale => 2, :default => 0.0, :null => false
    t.decimal  "discount",       :precision => 12, :scale => 6, :default => 0.0, :null => false
    t.integer  "tax_type_id"
    t.datetime "created_at",                                                     :null => false
    t.datetime "updated_at",                                                     :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "pre_invoice_items", ["measure_id"], :name => "index_pre_invoice_items_on_measure_id"
  add_index "pre_invoice_items", ["pre_invoice_id"], :name => "index_pre_invoice_items_on_pre_invoice_id"
  add_index "pre_invoice_items", ["product_id"], :name => "index_pre_invoice_items_on_product_id"
  add_index "pre_invoice_items", ["tariff_id"], :name => "index_pre_invoice_items_on_tariff_id"
  add_index "pre_invoice_items", ["tax_type_id"], :name => "index_pre_invoice_items_on_tax_type_id"

  create_table "pre_invoices", :force => true do |t|
    t.string   "invoice_no"
    t.date     "invoice_date"
    t.integer  "pre_bill_id"
    t.integer  "invoice_type_id"
    t.integer  "invoice_operation_id"
    t.integer  "invoice_status_id"
    t.integer  "billing_period_id"
    t.integer  "consumption"
    t.integer  "consumption_real"
    t.integer  "consumption_estimated"
    t.integer  "consumption_other"
    t.integer  "tariff_scheme_id"
    t.integer  "biller_id"
    t.decimal  "discount_pct",          :precision => 6,  :scale => 2, :default => 0.0, :null => false
    t.decimal  "exemption",             :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.integer  "charge_account_id"
    t.integer  "invoice_id"
    t.datetime "confirmation_date"
    t.datetime "created_at",                                                            :null => false
    t.datetime "updated_at",                                                            :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.date     "payday_limit"
    t.datetime "reading_1_date"
    t.datetime "reading_2_date"
    t.integer  "reading_1_index"
    t.integer  "reading_2_index"
    t.decimal  "totals",                :precision => 13, :scale => 4, :default => 0.0, :null => false
  end

  add_index "pre_invoices", ["biller_id"], :name => "index_pre_invoices_on_biller_id"
  add_index "pre_invoices", ["billing_period_id"], :name => "index_pre_invoices_on_billing_period_id"
  add_index "pre_invoices", ["charge_account_id"], :name => "index_pre_invoices_on_charge_account_id"
  add_index "pre_invoices", ["invoice_operation_id"], :name => "index_pre_invoices_on_invoice_operation_id"
  add_index "pre_invoices", ["invoice_status_id"], :name => "index_pre_invoices_on_invoice_status_id"
  add_index "pre_invoices", ["invoice_type_id"], :name => "index_pre_invoices_on_invoice_type_id"
  add_index "pre_invoices", ["pre_bill_id"], :name => "index_pre_invoices_on_pre_bill_id"
  add_index "pre_invoices", ["tariff_scheme_id"], :name => "index_pre_invoices_on_tariff_scheme_id"

  create_table "pre_reading_incidences", :force => true do |t|
    t.integer  "pre_reading_id"
    t.integer  "reading_incidence_type_id"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  create_table "pre_readings", :force => true do |t|
    t.integer  "project_id"
    t.integer  "billing_period_id"
    t.integer  "billing_frequency_id"
    t.integer  "reading_type_id"
    t.integer  "meter_id"
    t.integer  "subscriber_id"
    t.integer  "reading_route_id"
    t.integer  "reading_sequence"
    t.string   "reading_variant"
    t.datetime "reading_date"
    t.integer  "reading_index"
    t.integer  "reading_1_id"
    t.integer  "reading_2_id"
    t.integer  "reading_index_1"
    t.integer  "reading_index_2"
    t.datetime "created_at",                                                               :null => false
    t.datetime "updated_at",                                                               :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.decimal  "lat",                                      :precision => 18, :scale => 15
    t.decimal  "lng",                                      :precision => 18, :scale => 15
    t.binary   "image",                :limit => 16777215
  end

  add_index "pre_readings", ["billing_frequency_id"], :name => "index_pre_readings_on_billing_frequency_id"
  add_index "pre_readings", ["billing_period_id"], :name => "index_pre_readings_on_billing_period_id"
  add_index "pre_readings", ["meter_id"], :name => "index_pre_readings_on_meter_id"
  add_index "pre_readings", ["project_id", "billing_period_id", "reading_type_id", "meter_id", "subscriber_id", "reading_date"], :name => "index_pre_readings_unique", :unique => true
  add_index "pre_readings", ["project_id"], :name => "index_pre_readings_on_project_id"
  add_index "pre_readings", ["reading_1_id"], :name => "index_pre_readings_on_reading_1_id"
  add_index "pre_readings", ["reading_2_id"], :name => "index_pre_readings_on_reading_2_id"
  add_index "pre_readings", ["reading_date"], :name => "index_pre_readings_on_reading_date"
  add_index "pre_readings", ["reading_route_id"], :name => "index_pre_readings_on_reading_route_id"
  add_index "pre_readings", ["reading_type_id"], :name => "index_pre_readings_on_reading_type_id"
  add_index "pre_readings", ["subscriber_id"], :name => "index_pre_readings_on_subscriber_id"

  create_table "processed_file_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "processed_file_types", ["name"], :name => "index_processed_file_types_on_name"

  create_table "processed_files", :force => true do |t|
    t.string   "filename"
    t.integer  "processed_file_type_id"
    t.integer  "flow",                   :limit => 2
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "processed_files", ["filename"], :name => "index_processed_files_on_filename"
  add_index "processed_files", ["flow"], :name => "index_processed_files_on_flow"
  add_index "processed_files", ["processed_file_type_id"], :name => "index_processed_files_on_processed_file_type_id"

  create_table "product_company_prices", :force => true do |t|
    t.integer  "product_id"
    t.integer  "company_id"
    t.decimal  "last_price",       :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.decimal  "average_price",    :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.datetime "created_at",                                                       :null => false
    t.datetime "updated_at",                                                       :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.decimal  "prev_last_price",  :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.integer  "supplier_id"
    t.integer  "prev_supplier_id"
  end

  add_index "product_company_prices", ["company_id"], :name => "index_product_company_prices_on_company_id"
  add_index "product_company_prices", ["product_id", "company_id"], :name => "index_product_company_prices_on_product_and_company", :unique => true
  add_index "product_company_prices", ["product_id"], :name => "index_product_company_prices_on_product_id"
  add_index "product_company_prices", ["supplier_id"], :name => "index_product_company_prices_on_supplier_id"

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
    t.boolean  "is_meter"
    t.boolean  "no_order_needed"
  end

  add_index "product_families", ["family_code"], :name => "index_product_families_on_family_code"
  add_index "product_families", ["name"], :name => "index_product_families_on_name"
  add_index "product_families", ["organization_id", "family_code"], :name => "index_product_families_on_organization_id_and_family_code", :unique => true
  add_index "product_families", ["organization_id"], :name => "index_product_families_on_organization_id"

  create_table "product_family_stocks", :id => false, :force => true do |t|
    t.integer "product_family_id",                                :default => 0, :null => false
    t.string  "family_code"
    t.string  "family_name"
    t.integer "store_id"
    t.string  "store_name"
    t.decimal "initial",           :precision => 34, :scale => 4
    t.decimal "current",           :precision => 34, :scale => 4
  end

  create_table "product_family_stocks_manual", :id => false, :force => true do |t|
    t.integer "family_id",                                  :default => 0, :null => false
    t.string  "family_code"
    t.string  "family_name"
    t.integer "store_id"
    t.string  "store_name"
    t.decimal "initial",     :precision => 34, :scale => 4
    t.decimal "current",     :precision => 34, :scale => 4
  end

  create_table "product_types", :force => true do |t|
    t.string   "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  create_table "product_valued_stock_by_companies", :id => false, :force => true do |t|
    t.integer "store_id"
    t.string  "store_name"
    t.integer "product_family_id",                                    :default => 0,   :null => false
    t.string  "family_code"
    t.string  "family_name"
    t.integer "product_id",                                           :default => 0,   :null => false
    t.string  "product_code"
    t.string  "main_description"
    t.decimal "average_price",         :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.decimal "initial",               :precision => 34, :scale => 4
    t.decimal "current",               :precision => 34, :scale => 4
    t.decimal "current_value",         :precision => 13, :scale => 4
    t.integer "company_id"
    t.decimal "company_average_price", :precision => 12, :scale => 4, :default => 0.0
    t.decimal "company_current_value", :precision => 13, :scale => 4
  end

  create_table "product_valued_stocks", :id => false, :force => true do |t|
    t.integer "store_id"
    t.string  "store_name"
    t.integer "product_family_id",                                :default => 0,   :null => false
    t.string  "family_code"
    t.string  "family_name"
    t.integer "product_id",                                       :default => 0,   :null => false
    t.string  "product_code"
    t.string  "main_description"
    t.decimal "average_price",     :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.decimal "initial",           :precision => 34, :scale => 4
    t.decimal "current",           :precision => 34, :scale => 4
    t.decimal "current_value",     :precision => 13, :scale => 4
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
    t.decimal  "reference_price",                  :precision => 12, :scale => 4, :default => 0.0,  :null => false
    t.decimal  "last_price",                       :precision => 12, :scale => 4, :default => 0.0,  :null => false
    t.decimal  "average_price",                    :precision => 12, :scale => 4, :default => 0.0,  :null => false
    t.decimal  "sell_price",                       :precision => 12, :scale => 4, :default => 0.0,  :null => false
    t.decimal  "markup",                           :precision => 6,  :scale => 2, :default => 0.0,  :null => false
    t.integer  "warranty_time",       :limit => 2,                                :default => 0,    :null => false
    t.integer  "life_time",           :limit => 2,                                :default => 0,    :null => false
    t.boolean  "active",                                                          :default => true, :null => false
    t.string   "aux_code"
    t.string   "remarks"
    t.datetime "created_at",                                                                        :null => false
    t.datetime "updated_at",                                                                        :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.decimal  "prev_last_price",                  :precision => 12, :scale => 4, :default => 0.0,  :null => false
    t.integer  "organization_id"
  end

  add_index "products", ["active"], :name => "index_products_on_active"
  add_index "products", ["aux_description"], :name => "index_products_on_aux_description"
  add_index "products", ["main_description"], :name => "index_products_on_main_description"
  add_index "products", ["manufacturer_id"], :name => "index_products_on_manufacturer_id"
  add_index "products", ["manufacturer_p_code"], :name => "index_products_on_manufacturer_p_code"
  add_index "products", ["measure_id"], :name => "index_products_on_measure_id"
  add_index "products", ["organization_id", "product_code"], :name => "index_products_on_organization_id_and_product_code", :unique => true
  add_index "products", ["organization_id"], :name => "index_products_on_organization_id"
  add_index "products", ["product_code"], :name => "index_products_on_product_code"
  add_index "products", ["product_family_id"], :name => "index_products_on_product_family_id"
  add_index "products", ["product_type_id"], :name => "index_products_on_product_type_id"
  add_index "products", ["tax_type_id"], :name => "index_products_on_tax_type_id"

  create_table "professional_groups", :force => true do |t|
    t.string   "name"
    t.string   "pg_code"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.string   "nomina_id"
    t.integer  "organization_id"
  end

  add_index "professional_groups", ["nomina_id"], :name => "index_professional_groups_on_nomina_id"
  add_index "professional_groups", ["organization_id", "pg_code"], :name => "index_professional_groups_on_organization_id_and_pg_code", :unique => true
  add_index "professional_groups", ["organization_id"], :name => "index_professional_groups_on_organization_id"
  add_index "professional_groups", ["pg_code"], :name => "index_professional_groups_on_pg_code"

  create_table "project_types", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "project_types", ["code"], :name => "index_project_types_on_code"

  create_table "projects", :force => true do |t|
    t.string   "name"
    t.date     "opened_at"
    t.date     "closed_at"
    t.integer  "office_id"
    t.integer  "company_id"
    t.datetime "created_at",                                                        :null => false
    t.datetime "updated_at",                                                        :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.string   "project_code"
    t.integer  "organization_id"
    t.integer  "project_type_id"
    t.decimal  "max_order_total",   :precision => 13, :scale => 4, :default => 0.0, :null => false
    t.decimal  "max_order_price",   :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.integer  "ledger_account_id"
  end

  add_index "projects", ["company_id"], :name => "index_projects_on_company_id"
  add_index "projects", ["ledger_account_id"], :name => "index_projects_on_ledger_account_id"
  add_index "projects", ["name"], :name => "index_projects_on_name"
  add_index "projects", ["office_id"], :name => "index_projects_on_office_id"
  add_index "projects", ["organization_id", "project_code"], :name => "index_projects_on_organization_id_and_project_code", :unique => true
  add_index "projects", ["organization_id"], :name => "index_projects_on_organization_id"
  add_index "projects", ["project_code"], :name => "index_projects_on_project_code"
  add_index "projects", ["project_type_id"], :name => "index_projects_on_project_type_id"

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

  create_table "purchase_order_item_balances", :id => false, :force => true do |t|
    t.integer "purchase_order_item_id",                                      :default => 0,   :null => false
    t.decimal "purchase_order_item_quantity", :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.decimal "receipt_quantity",             :precision => 34, :scale => 4
    t.decimal "balance",                      :precision => 35, :scale => 4
  end

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
    t.integer  "organization_id"
    t.integer  "approver_id"
    t.datetime "approval_date"
    t.string   "store_address_1"
    t.string   "store_address_2"
    t.string   "store_phones"
    t.decimal  "totals",            :precision => 13, :scale => 4, :default => 0.0, :null => false
  end

  add_index "purchase_orders", ["approver_id"], :name => "index_purchase_orders_on_approver_id"
  add_index "purchase_orders", ["charge_account_id"], :name => "index_purchase_orders_on_charge_account_id"
  add_index "purchase_orders", ["created_by"], :name => "index_purchase_orders_on_created_by"
  add_index "purchase_orders", ["offer_id"], :name => "index_purchase_orders_on_offer_id"
  add_index "purchase_orders", ["order_date"], :name => "index_purchase_orders_on_order_date"
  add_index "purchase_orders", ["order_no"], :name => "index_purchase_orders_on_order_no"
  add_index "purchase_orders", ["order_status_id"], :name => "index_purchase_orders_on_order_status_id"
  add_index "purchase_orders", ["organization_id", "order_no"], :name => "index_purchase_orders_on_organization_id_and_order_no", :unique => true
  add_index "purchase_orders", ["organization_id"], :name => "index_purchase_orders_on_organization_id"
  add_index "purchase_orders", ["payment_method_id"], :name => "index_purchase_orders_on_payment_method_id"
  add_index "purchase_orders", ["project_id"], :name => "index_purchase_orders_on_project_id"
  add_index "purchase_orders", ["store_id"], :name => "index_purchase_orders_on_store_id"
  add_index "purchase_orders", ["supplier_id"], :name => "index_purchase_orders_on_supplier_id"
  add_index "purchase_orders", ["work_order_id"], :name => "index_purchase_orders_on_work_order_id"

  create_table "purchase_prices", :force => true do |t|
    t.integer  "product_id"
    t.integer  "supplier_id"
    t.string   "code"
    t.decimal  "price",              :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.integer  "measure_id"
    t.decimal  "factor",             :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.boolean  "favorite"
    t.datetime "created_at",                                                         :null => false
    t.datetime "updated_at",                                                         :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.string   "prev_code"
    t.decimal  "prev_price",         :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.decimal  "discount_rate",      :precision => 12, :scale => 2, :default => 0.0, :null => false
    t.decimal  "prev_discount_rate", :precision => 12, :scale => 2, :default => 0.0, :null => false
  end

  add_index "purchase_prices", ["code"], :name => "index_purchase_prices_on_code"
  add_index "purchase_prices", ["measure_id"], :name => "index_purchase_prices_on_measure_id"
  add_index "purchase_prices", ["product_id"], :name => "index_purchase_prices_on_product_id"
  add_index "purchase_prices", ["supplier_id"], :name => "index_purchase_prices_on_supplier_id"

  create_table "ratio_groups", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.integer  "organization_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "ratio_groups", ["code"], :name => "index_ratio_groups_on_code"
  add_index "ratio_groups", ["organization_id", "code"], :name => "index_ratio_groups_on_organization_and_code", :unique => true
  add_index "ratio_groups", ["organization_id"], :name => "index_ratio_groups_on_organization_id"

  create_table "ratios", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.integer  "organization_id"
    t.integer  "ratio_group_id"
    t.string   "formula"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "ratios", ["code"], :name => "index_ratios_on_code"
  add_index "ratios", ["organization_id", "ratio_group_id", "code"], :name => "index_ratios_on_organization_group_code", :unique => true
  add_index "ratios", ["organization_id"], :name => "index_ratios_on_organization_id"
  add_index "ratios", ["ratio_group_id"], :name => "index_ratios_on_ratio_group_id"

  create_table "reading_incidence_types", :force => true do |t|
    t.string   "name"
    t.boolean  "should_estimate"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.boolean  "is_main"
    t.string   "code",            :limit => 2
  end

  add_index "reading_incidence_types", ["code"], :name => "index_reading_incidence_types_on_code"

  create_table "reading_incidences", :force => true do |t|
    t.integer  "reading_id"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.integer  "reading_incidence_type_id"
  end

  add_index "reading_incidences", ["reading_id"], :name => "index_reading_incidences_on_reading_id"
  add_index "reading_incidences", ["reading_incidence_type_id"], :name => "index_reading_incidences_on_reading_incidence_type_id"

  create_table "reading_routes", :force => true do |t|
    t.integer  "project_id"
    t.integer  "office_id"
    t.string   "routing_code"
    t.string   "name"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "reading_routes", ["office_id", "routing_code"], :name => "index_reading_routes_unique", :unique => true
  add_index "reading_routes", ["office_id"], :name => "index_reading_routes_on_office_id"
  add_index "reading_routes", ["project_id"], :name => "index_reading_routes_on_project_id"
  add_index "reading_routes", ["routing_code"], :name => "index_reading_routes_on_routing_code"

  create_table "reading_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  create_table "readings", :force => true do |t|
    t.integer  "project_id"
    t.integer  "billing_period_id"
    t.integer  "billing_frequency_id"
    t.integer  "reading_type_id"
    t.integer  "meter_id"
    t.integer  "subscriber_id"
    t.integer  "reading_route_id"
    t.integer  "reading_sequence"
    t.string   "reading_variant"
    t.datetime "reading_date"
    t.integer  "reading_index",                                                            :default => 0, :null => false
    t.datetime "created_at",                                                                              :null => false
    t.datetime "updated_at",                                                                              :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.integer  "invoice_id"
    t.integer  "reading_index_1"
    t.integer  "reading_index_2"
    t.integer  "reading_1_id"
    t.integer  "reading_2_id"
    t.integer  "bill_id"
    t.decimal  "lat",                                      :precision => 18, :scale => 15
    t.decimal  "lng",                                      :precision => 18, :scale => 15
    t.binary   "image",                :limit => 16777215
  end

  add_index "readings", ["bill_id"], :name => "index_readings_on_bill_id"
  add_index "readings", ["billing_frequency_id"], :name => "index_readings_on_billing_frequency_id"
  add_index "readings", ["billing_period_id"], :name => "index_readings_on_billing_period_id"
  add_index "readings", ["invoice_id"], :name => "index_readings_on_invoice_id"
  add_index "readings", ["meter_id"], :name => "index_readings_on_meter_id"
  add_index "readings", ["project_id", "billing_period_id", "reading_type_id", "meter_id", "subscriber_id", "reading_date"], :name => "index_readings_unique", :unique => true
  add_index "readings", ["project_id"], :name => "index_readings_on_project_id"
  add_index "readings", ["reading_date"], :name => "index_readings_on_reading_date"
  add_index "readings", ["reading_route_id"], :name => "index_readings_on_reading_route_id"
  add_index "readings", ["reading_type_id"], :name => "index_readings_on_reading_type_id"
  add_index "readings", ["subscriber_id"], :name => "index_readings_on_subscriber_id"

  create_table "receipt_note_item_balances", :id => false, :force => true do |t|
    t.integer "receipt_note_item_id",                                      :default => 0,   :null => false
    t.decimal "receipt_note_item_quantity", :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.decimal "invoiced_quantity",          :precision => 34, :scale => 4
    t.decimal "balance",                    :precision => 35, :scale => 4
  end

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
    t.decimal  "discount_pct",            :precision => 6,  :scale => 2, :default => 0.0, :null => false
    t.decimal  "discount",                :precision => 13, :scale => 4, :default => 0.0, :null => false
    t.integer  "project_id"
    t.integer  "store_id"
    t.integer  "work_order_id"
    t.integer  "charge_account_id"
    t.decimal  "retention_pct",           :precision => 6,  :scale => 2, :default => 0.0, :null => false
    t.integer  "retention_time"
    t.datetime "created_at",                                                              :null => false
    t.datetime "updated_at",                                                              :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.integer  "purchase_order_id"
    t.integer  "organization_id"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.decimal  "totals",                  :precision => 13, :scale => 4, :default => 0.0, :null => false
  end

  add_index "receipt_notes", ["charge_account_id"], :name => "index_receipt_notes_on_charge_account_id"
  add_index "receipt_notes", ["organization_id", "supplier_id", "receipt_no"], :name => "index_receipt_notes_on_organization_and_supplier_and_no", :unique => true
  add_index "receipt_notes", ["organization_id"], :name => "index_receipt_notes_on_organization_id"
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

  create_table "regulation_types", :force => true do |t|
    t.string   "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  create_table "regulations", :force => true do |t|
    t.integer  "project_id"
    t.integer  "regulation_type_id"
    t.string   "description"
    t.date     "starting_at"
    t.date     "ending_at"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "regulations", ["project_id"], :name => "index_regulations_on_project_id"
  add_index "regulations", ["regulation_type_id"], :name => "index_regulations_on_regulation_type_id"

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
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.string   "nomina_id"
    t.integer  "organization_id"
  end

  add_index "salary_concepts", ["name"], :name => "index_salary_concepts_on_name"
  add_index "salary_concepts", ["nomina_id"], :name => "index_salary_concepts_on_nomina_id"
  add_index "salary_concepts", ["organization_id"], :name => "index_salary_concepts_on_organization_id"

  create_table "sale_offer_item_balances", :id => false, :force => true do |t|
    t.integer "sale_offer_item_id",                                      :default => 0,   :null => false
    t.decimal "sale_offer_item_quantity", :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.decimal "invoiced_quantity",        :precision => 34, :scale => 4
    t.decimal "balance",                  :precision => 35, :scale => 4
  end

  create_table "sale_offer_items", :force => true do |t|
    t.integer  "sale_offer_id"
    t.integer  "product_id"
    t.string   "description"
    t.decimal  "quantity",          :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.decimal  "price",             :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.decimal  "discount_pct",      :precision => 6,  :scale => 2, :default => 0.0, :null => false
    t.decimal  "discount",          :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.integer  "tax_type_id"
    t.date     "delivery_date"
    t.integer  "project_id"
    t.integer  "store_id"
    t.integer  "work_order_id"
    t.integer  "charge_account_id"
    t.datetime "created_at",                                                        :null => false
    t.datetime "updated_at",                                                        :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "sale_offer_items", ["charge_account_id"], :name => "index_sale_offer_items_on_charge_account_id"
  add_index "sale_offer_items", ["description"], :name => "index_sale_offer_items_on_description"
  add_index "sale_offer_items", ["product_id"], :name => "index_sale_offer_items_on_product_id"
  add_index "sale_offer_items", ["project_id"], :name => "index_sale_offer_items_on_project_id"
  add_index "sale_offer_items", ["sale_offer_id"], :name => "index_sale_offer_items_on_sale_offer_id"
  add_index "sale_offer_items", ["store_id"], :name => "index_sale_offer_items_on_store_id"
  add_index "sale_offer_items", ["tax_type_id"], :name => "index_sale_offer_items_on_tax_type_id"
  add_index "sale_offer_items", ["work_order_id"], :name => "index_sale_offer_items_on_work_order_id"

  create_table "sale_offer_statuses", :force => true do |t|
    t.string   "name"
    t.boolean  "approval"
    t.boolean  "notification"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "sale_offer_statuses", ["name"], :name => "index_sale_offer_statuses_on_name"

  create_table "sale_offers", :force => true do |t|
    t.integer  "client_id"
    t.integer  "payment_method_id"
    t.integer  "sale_offer_status_id"
    t.string   "offer_no"
    t.date     "offer_date"
    t.string   "remarks"
    t.decimal  "discount_pct",           :precision => 6,  :scale => 2, :default => 0.0, :null => false
    t.decimal  "discount",               :precision => 13, :scale => 4, :default => 0.0, :null => false
    t.integer  "project_id"
    t.integer  "store_id"
    t.integer  "work_order_id"
    t.integer  "charge_account_id"
    t.integer  "organization_id"
    t.datetime "created_at",                                                             :null => false
    t.datetime "updated_at",                                                             :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.integer  "contracting_request_id"
    t.datetime "approval_date"
    t.string   "approver"
    t.integer  "invoices_count",                                        :default => 0
  end

  add_index "sale_offers", ["charge_account_id"], :name => "index_sale_offers_on_charge_account_id"
  add_index "sale_offers", ["client_id"], :name => "index_sale_offers_on_client_id"
  add_index "sale_offers", ["contracting_request_id"], :name => "index_sale_offers_on_contracting_request_id"
  add_index "sale_offers", ["offer_date"], :name => "index_sale_offers_on_offer_date"
  add_index "sale_offers", ["offer_no"], :name => "index_sale_offers_on_offer_no"
  add_index "sale_offers", ["organization_id", "offer_no"], :name => "index_sale_offers_on_organization_id_and_offer_no", :unique => true
  add_index "sale_offers", ["organization_id"], :name => "index_sale_offers_on_organization_id"
  add_index "sale_offers", ["payment_method_id"], :name => "index_sale_offers_on_payment_method_id"
  add_index "sale_offers", ["project_id"], :name => "index_sale_offers_on_project_id"
  add_index "sale_offers", ["sale_offer_status_id"], :name => "index_sale_offers_on_sale_offer_status_id"
  add_index "sale_offers", ["store_id"], :name => "index_sale_offers_on_store_id"
  add_index "sale_offers", ["work_order_id"], :name => "index_sale_offers_on_work_order_id"

  create_table "sepa_scheme_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "service_point_locations", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  create_table "service_point_purposes", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  create_table "service_point_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  create_table "service_points", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.integer  "service_point_type_id"
    t.integer  "service_point_location_id"
    t.integer  "service_point_purpose_id"
    t.integer  "water_connection_id"
    t.integer  "organization_id"
    t.integer  "company_id"
    t.integer  "office_id"
    t.string   "cadastral_reference"
    t.string   "gis_id"
    t.integer  "street_directory_id"
    t.string   "street_number"
    t.string   "building"
    t.string   "floor"
    t.string   "floor_office"
    t.integer  "zipcode_id"
    t.integer  "diameter"
    t.boolean  "verified"
    t.boolean  "available_for_contract"
    t.integer  "reading_route_id"
    t.integer  "reading_sequence"
    t.string   "reading_variant"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.string   "km"
    t.integer  "center_id"
    t.string   "pub_record"
  end

  add_index "service_points", ["cadastral_reference"], :name => "index_service_points_on_cadastral_reference"
  add_index "service_points", ["center_id"], :name => "index_service_points_on_center_id"
  add_index "service_points", ["code"], :name => "index_service_points_on_code"
  add_index "service_points", ["company_id"], :name => "index_service_points_on_company_id"
  add_index "service_points", ["gis_id"], :name => "index_service_points_on_gis_id"
  add_index "service_points", ["name"], :name => "index_service_points_on_name"
  add_index "service_points", ["office_id"], :name => "index_service_points_on_office_id"
  add_index "service_points", ["organization_id"], :name => "index_service_points_on_organization_id"
  add_index "service_points", ["pub_record"], :name => "index_service_points_on_pub_record"
  add_index "service_points", ["reading_route_id"], :name => "index_service_points_on_reading_route_id"
  add_index "service_points", ["reading_sequence"], :name => "index_service_points_on_reading_sequence"
  add_index "service_points", ["reading_variant"], :name => "index_service_points_on_reading_variant"
  add_index "service_points", ["service_point_location_id"], :name => "index_service_points_on_service_point_location_id"
  add_index "service_points", ["service_point_purpose_id"], :name => "index_service_points_on_service_point_purpose_id"
  add_index "service_points", ["service_point_type_id"], :name => "index_service_points_on_service_point_type_id"
  add_index "service_points", ["street_directory_id"], :name => "index_service_points_on_street_directory_id"
  add_index "service_points", ["water_connection_id"], :name => "index_service_points_on_water_connection_id"
  add_index "service_points", ["zipcode_id"], :name => "index_service_points_on_zipcode_id"

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
    t.integer  "organization_id"
  end

  add_index "shared_contacts", ["cellular"], :name => "index_shared_contacts_on_cellular"
  add_index "shared_contacts", ["company"], :name => "index_shared_contacts_on_company"
  add_index "shared_contacts", ["country_id"], :name => "index_shared_contacts_on_country_id"
  add_index "shared_contacts", ["email"], :name => "index_shared_contacts_on_email"
  add_index "shared_contacts", ["first_name"], :name => "index_shared_contacts_on_first_name"
  add_index "shared_contacts", ["fiscal_id"], :name => "index_shared_contacts_on_fiscal_id"
  add_index "shared_contacts", ["last_name"], :name => "index_shared_contacts_on_last_name"
  add_index "shared_contacts", ["organization_id"], :name => "index_shared_contacts_on_organization_id"
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

  create_table "store_offices", :force => true do |t|
    t.integer  "store_id"
    t.integer  "office_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "store_offices", ["office_id"], :name => "index_store_offices_on_office_id"
  add_index "store_offices", ["store_id"], :name => "index_store_offices_on_store_id"

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
    t.string   "email"
  end

  add_index "stores", ["company_id"], :name => "index_stores_on_company_id"
  add_index "stores", ["name"], :name => "index_stores_on_name"
  add_index "stores", ["office_id"], :name => "index_stores_on_office_id"
  add_index "stores", ["organization_id"], :name => "index_stores_on_organization_id"
  add_index "stores", ["province_id"], :name => "index_stores_on_province_id"
  add_index "stores", ["street_type_id"], :name => "index_stores_on_street_type_id"
  add_index "stores", ["supplier_id"], :name => "index_stores_on_supplier_id"
  add_index "stores", ["town_id"], :name => "index_stores_on_town_id"
  add_index "stores", ["zipcode_id"], :name => "index_stores_on_zipcode_id"

  create_table "street_directories", :force => true do |t|
    t.integer  "town_id"
    t.integer  "street_type_id"
    t.string   "street_name"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.integer  "zipcode_id"
    t.string   "alt_code"
  end

  add_index "street_directories", ["alt_code"], :name => "index_street_directories_on_alt_code"
  add_index "street_directories", ["street_name"], :name => "index_street_directories_on_street_name"
  add_index "street_directories", ["street_type_id"], :name => "index_street_directories_on_street_type_id"
  add_index "street_directories", ["town_id"], :name => "index_street_directories_on_town_id"
  add_index "street_directories", ["zipcode_id"], :name => "index_street_directories_on_zipcode_id"

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

  create_table "subscriber_annotation_classes", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.integer  "class_type", :limit => 1, :default => 1, :null => false
  end

  add_index "subscriber_annotation_classes", ["class_type"], :name => "index_subscriber_annotation_classes_on_class_type"
  add_index "subscriber_annotation_classes", ["code"], :name => "index_subscriber_annotation_classes_on_code"

  create_table "subscriber_annotations", :force => true do |t|
    t.integer  "subscriber_id"
    t.string   "annotation"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.integer  "subscriber_annotation_class_id"
  end

  add_index "subscriber_annotations", ["created_at"], :name => "index_subscriber_annotations_on_created_at"
  add_index "subscriber_annotations", ["created_by"], :name => "index_subscriber_annotations_on_created_by"
  add_index "subscriber_annotations", ["subscriber_annotation_class_id"], :name => "index_subscriber_annotations_on_subscriber_annotation_class_id"
  add_index "subscriber_annotations", ["subscriber_id"], :name => "index_subscriber_annotations_on_subscriber_id"

  create_table "subscriber_filiations", :id => false, :force => true do |t|
    t.integer "subscriber_id",                      :default => 0, :null => false
    t.string  "subscriber_code",     :limit => 12
    t.string  "name",                :limit => 512
    t.text    "supply_address"
    t.string  "meter_code"
    t.integer "use_id"
    t.integer "reading_route_id"
    t.integer "office_id"
    t.integer "center_id"
    t.integer "street_directory_id"
    t.text    "everything"
  end

  create_table "subscriber_supply_addresses", :id => false, :force => true do |t|
    t.integer "subscriber_id",  :default => 0, :null => false
    t.text    "supply_address"
  end

  create_table "subscriber_tariffs", :force => true do |t|
    t.integer  "subscriber_id"
    t.integer  "tariff_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.date     "starting_at"
    t.date     "ending_at"
  end

  add_index "subscriber_tariffs", ["ending_at"], :name => "index_subscriber_tariffs_on_ending_at"
  add_index "subscriber_tariffs", ["starting_at"], :name => "index_subscriber_tariffs_on_starting_at"
  add_index "subscriber_tariffs", ["subscriber_id"], :name => "index_subscriber_tariffs_on_subscriber_id"
  add_index "subscriber_tariffs", ["tariff_id"], :name => "index_subscriber_tariffs_on_tariff_id"

  create_table "subscribers", :force => true do |t|
    t.integer  "client_id"
    t.integer  "office_id"
    t.integer  "center_id"
    t.string   "subscriber_code"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "company"
    t.string   "fiscal_id"
    t.date     "starting_at"
    t.date     "ending_at"
    t.integer  "street_directory_id"
    t.datetime "created_at",                                                                           :null => false
    t.datetime "updated_at",                                                                           :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.string   "street_number"
    t.string   "building"
    t.string   "floor"
    t.string   "floor_office"
    t.integer  "zipcode_id"
    t.string   "phone"
    t.string   "fax"
    t.string   "cellular"
    t.string   "email"
    t.integer  "service_point_id"
    t.boolean  "active",                                                             :default => true, :null => false
    t.integer  "tariff_scheme_id"
    t.integer  "billing_frequency_id"
    t.integer  "meter_id"
    t.integer  "reading_route_id"
    t.integer  "reading_sequence"
    t.string   "reading_variant"
    t.integer  "contracting_request_id"
    t.string   "remarks"
    t.string   "cadastral_reference"
    t.string   "gis_id"
    t.integer  "endowments",             :limit => 2,                                :default => 0,    :null => false
    t.integer  "inhabitants",            :limit => 2,                                :default => 0,    :null => false
    t.string   "km"
    t.string   "gis_id_wc"
    t.string   "pub_record"
    t.integer  "use_id"
    t.decimal  "m2",                                  :precision => 12, :scale => 4, :default => 0.0,  :null => false
    t.decimal  "equiv_dwelling",                      :precision => 12, :scale => 4, :default => 0.0,  :null => false
    t.decimal  "deposit",                             :precision => 13, :scale => 4, :default => 0.0,  :null => false
  end

  add_index "subscribers", ["billing_frequency_id"], :name => "index_subscribers_on_billing_frequency_id"
  add_index "subscribers", ["cadastral_reference"], :name => "index_subscribers_on_cadastral_reference"
  add_index "subscribers", ["cellular"], :name => "index_subscribers_on_cellular"
  add_index "subscribers", ["center_id"], :name => "index_subscribers_on_center_id"
  add_index "subscribers", ["client_id"], :name => "index_subscribers_on_client_id"
  add_index "subscribers", ["company"], :name => "index_subscribers_on_company"
  add_index "subscribers", ["contracting_request_id"], :name => "index_subscribers_on_contracting_request_id"
  add_index "subscribers", ["email"], :name => "index_subscribers_on_email"
  add_index "subscribers", ["first_name"], :name => "index_subscribers_on_first_name"
  add_index "subscribers", ["fiscal_id"], :name => "index_subscribers_on_fiscal_id"
  add_index "subscribers", ["gis_id"], :name => "index_subscribers_on_gis_id"
  add_index "subscribers", ["last_name"], :name => "index_subscribers_on_last_name"
  add_index "subscribers", ["meter_id"], :name => "index_subscribers_on_meter_id"
  add_index "subscribers", ["office_id", "subscriber_code"], :name => "index_subscribers_unique", :unique => true
  add_index "subscribers", ["office_id"], :name => "index_subscribers_on_office_id"
  add_index "subscribers", ["phone"], :name => "index_subscribers_on_phone"
  add_index "subscribers", ["pub_record"], :name => "index_subscribers_on_pub_record"
  add_index "subscribers", ["reading_route_id"], :name => "index_subscribers_on_reading_route_id"
  add_index "subscribers", ["reading_sequence"], :name => "index_subscribers_on_reading_sequence"
  add_index "subscribers", ["reading_variant"], :name => "index_subscribers_on_reading_variant"
  add_index "subscribers", ["service_point_id"], :name => "index_subscribers_on_service_point_id"
  add_index "subscribers", ["street_directory_id"], :name => "index_subscribers_on_street_directory_id"
  add_index "subscribers", ["subscriber_code"], :name => "index_subscribers_on_subscriber_code"
  add_index "subscribers", ["tariff_scheme_id"], :name => "index_subscribers_on_tariff_scheme_id"
  add_index "subscribers", ["use_id"], :name => "index_subscribers_on_use_id"
  add_index "subscribers", ["zipcode_id"], :name => "index_subscribers_on_zipcode_id"

  create_table "supplier_bank_accounts", :force => true do |t|
    t.integer  "supplier_id"
    t.integer  "bank_account_class_id"
    t.integer  "country_id"
    t.string   "iban_dc"
    t.integer  "bank_id"
    t.integer  "bank_office_id"
    t.string   "ccc_dc"
    t.string   "account_no"
    t.string   "holder_fiscal_id"
    t.string   "holder_name"
    t.date     "starting_at"
    t.date     "ending_at"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "supplier_bank_accounts", ["account_no"], :name => "index_supplier_bank_accounts_on_account_no"
  add_index "supplier_bank_accounts", ["bank_account_class_id"], :name => "index_supplier_bank_accounts_on_bank_account_class_id"
  add_index "supplier_bank_accounts", ["bank_id"], :name => "index_supplier_bank_accounts_on_bank_id"
  add_index "supplier_bank_accounts", ["bank_office_id"], :name => "index_supplier_bank_accounts_on_bank_office_id"
  add_index "supplier_bank_accounts", ["country_id"], :name => "index_supplier_bank_accounts_on_country_id"
  add_index "supplier_bank_accounts", ["holder_fiscal_id"], :name => "index_supplier_bank_accounts_on_holder_fiscal_id"
  add_index "supplier_bank_accounts", ["holder_name"], :name => "index_supplier_bank_accounts_on_holder_name"
  add_index "supplier_bank_accounts", ["supplier_id", "bank_account_class_id", "country_id", "iban_dc", "bank_id", "bank_office_id", "ccc_dc", "account_no"], :name => "index_supplier_bank_accounts_on_supplier_and_class_and_no", :unique => true
  add_index "supplier_bank_accounts", ["supplier_id"], :name => "index_supplier_bank_accounts_on_supplier_id"

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
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.string   "created_by"
    t.string   "updated_by"
    t.integer  "organization_id"
    t.boolean  "is_contact"
    t.integer  "shared_contact_id"
  end

  add_index "supplier_contacts", ["cellular"], :name => "index_supplier_contacts_on_cellular"
  add_index "supplier_contacts", ["email"], :name => "index_supplier_contacts_on_email"
  add_index "supplier_contacts", ["first_name"], :name => "index_supplier_contacts_on_first_name"
  add_index "supplier_contacts", ["fiscal_id"], :name => "index_supplier_contacts_on_fiscal_id"
  add_index "supplier_contacts", ["last_name"], :name => "index_supplier_contacts_on_last_name"
  add_index "supplier_contacts", ["organization_id"], :name => "index_supplier_contacts_on_organization_id"
  add_index "supplier_contacts", ["phone"], :name => "index_supplier_contacts_on_phone"
  add_index "supplier_contacts", ["shared_contact_id"], :name => "index_supplier_contacts_on_shared_contact_id"
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

  create_table "supplier_invoice_debts", :id => false, :force => true do |t|
    t.integer "supplier_invoice_id",                                 :default => 0, :null => false
    t.integer "organization_id"
    t.integer "supplier_id"
    t.string  "invoice_no"
    t.decimal "subtotal",            :precision => 47, :scale => 8
    t.decimal "taxes",               :precision => 65, :scale => 20
    t.decimal "bonus",               :precision => 57, :scale => 14
    t.decimal "taxable",             :precision => 58, :scale => 14
    t.decimal "total",               :precision => 65, :scale => 20
    t.decimal "paid",                :precision => 35, :scale => 4
    t.decimal "debt",                :precision => 65, :scale => 20
  end

  create_table "supplier_invoice_debts_manual", :id => false, :force => true do |t|
    t.integer "id",              :limit => 8
    t.integer "organization_id"
    t.string  "invoice_no"
    t.decimal "subtotal",                     :precision => 47, :scale => 8
    t.decimal "taxes",                        :precision => 65, :scale => 20
    t.decimal "bonus",                        :precision => 57, :scale => 14
    t.decimal "taxable",                      :precision => 58, :scale => 14
    t.decimal "total",                        :precision => 65, :scale => 20
    t.decimal "paid",                         :precision => 35, :scale => 4
    t.decimal "debt",                         :precision => 65, :scale => 20
  end

  create_table "supplier_invoice_items", :force => true do |t|
    t.integer  "supplier_invoice_id"
    t.integer  "receipt_note_id"
    t.integer  "receipt_note_item_id"
    t.integer  "product_id"
    t.string   "code"
    t.string   "description"
    t.decimal  "quantity",               :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.decimal  "price",                  :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.decimal  "discount_pct",           :precision => 6,  :scale => 2, :default => 0.0, :null => false
    t.decimal  "discount",               :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.integer  "tax_type_id"
    t.integer  "work_order_id"
    t.integer  "charge_account_id"
    t.datetime "created_at",                                                             :null => false
    t.datetime "updated_at",                                                             :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.integer  "project_id"
    t.integer  "purchase_order_id"
    t.integer  "purchase_order_item_id"
  end

  add_index "supplier_invoice_items", ["charge_account_id"], :name => "index_supplier_invoice_items_on_charge_account_id"
  add_index "supplier_invoice_items", ["code"], :name => "index_supplier_invoice_items_on_code"
  add_index "supplier_invoice_items", ["description"], :name => "index_supplier_invoice_items_on_description"
  add_index "supplier_invoice_items", ["product_id"], :name => "index_supplier_invoice_items_on_product_id"
  add_index "supplier_invoice_items", ["project_id"], :name => "index_supplier_invoice_items_on_project_id"
  add_index "supplier_invoice_items", ["purchase_order_id"], :name => "index_supplier_invoice_items_on_purchase_order_id"
  add_index "supplier_invoice_items", ["purchase_order_item_id"], :name => "index_supplier_invoice_items_on_purchase_order_item_id"
  add_index "supplier_invoice_items", ["receipt_note_id"], :name => "index_supplier_invoice_items_on_receipt_note_id"
  add_index "supplier_invoice_items", ["receipt_note_item_id"], :name => "index_supplier_invoice_items_on_receipt_note_item_id"
  add_index "supplier_invoice_items", ["supplier_invoice_id"], :name => "index_supplier_invoice_items_on_supplier_invoice_id"
  add_index "supplier_invoice_items", ["tax_type_id"], :name => "index_supplier_invoice_items_on_tax_type_id"
  add_index "supplier_invoice_items", ["work_order_id"], :name => "index_supplier_invoice_items_on_work_order_id"

  create_table "supplier_invoice_payments", :id => false, :force => true do |t|
    t.integer "supplier_invoice_id"
    t.decimal "paid",                :precision => 35, :scale => 4
  end

  create_table "supplier_invoices", :force => true do |t|
    t.string   "invoice_no"
    t.integer  "supplier_id"
    t.integer  "payment_method_id"
    t.date     "invoice_date"
    t.string   "remarks"
    t.decimal  "discount_pct",            :precision => 6,  :scale => 2, :default => 0.0, :null => false
    t.decimal  "discount",                :precision => 13, :scale => 4, :default => 0.0, :null => false
    t.integer  "project_id"
    t.integer  "work_order_id"
    t.integer  "charge_account_id"
    t.datetime "created_at",                                                              :null => false
    t.datetime "updated_at",                                                              :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.date     "posted_at"
    t.integer  "organization_id"
    t.integer  "receipt_note_id"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.decimal  "withholding",             :precision => 13, :scale => 4, :default => 0.0, :null => false
    t.string   "internal_no"
    t.integer  "purchase_order_id"
    t.decimal  "totals",                  :precision => 13, :scale => 4, :default => 0.0, :null => false
    t.date     "payday_limit"
    t.integer  "company_id"
  end

  add_index "supplier_invoices", ["charge_account_id"], :name => "index_supplier_invoices_on_charge_account_id"
  add_index "supplier_invoices", ["company_id"], :name => "index_supplier_invoices_on_company_id"
  add_index "supplier_invoices", ["internal_no"], :name => "index_supplier_invoices_on_internal_no"
  add_index "supplier_invoices", ["invoice_date"], :name => "index_supplier_invoices_on_invoice_date"
  add_index "supplier_invoices", ["invoice_no"], :name => "index_supplier_invoices_on_invoice_no"
  add_index "supplier_invoices", ["organization_id", "supplier_id", "invoice_no"], :name => "index_supplier_invoices_on_organization_and_supplier_and_no", :unique => true
  add_index "supplier_invoices", ["organization_id"], :name => "index_supplier_invoices_on_organization_id"
  add_index "supplier_invoices", ["payment_method_id"], :name => "index_supplier_invoices_on_payment_method_id"
  add_index "supplier_invoices", ["posted_at"], :name => "index_supplier_invoices_on_posted_at"
  add_index "supplier_invoices", ["project_id", "internal_no"], :name => "index_supplier_invoices_on_project_and_internal_no", :unique => true
  add_index "supplier_invoices", ["project_id"], :name => "index_supplier_invoices_on_project_id"
  add_index "supplier_invoices", ["purchase_order_id"], :name => "index_supplier_invoices_on_purchase_order_id"
  add_index "supplier_invoices", ["receipt_note_id"], :name => "index_supplier_invoices_on_receipt_note_id"
  add_index "supplier_invoices", ["supplier_id"], :name => "index_supplier_invoices_on_supplier_id"
  add_index "supplier_invoices", ["work_order_id"], :name => "index_supplier_invoices_on_work_order_id"

  create_table "supplier_ledger_accounts", :force => true do |t|
    t.integer  "supplier_id"
    t.integer  "ledger_account_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.integer  "company_id"
  end

  add_index "supplier_ledger_accounts", ["company_id"], :name => "index_supplier_ledger_accounts_on_company_id"
  add_index "supplier_ledger_accounts", ["ledger_account_id"], :name => "index_supplier_ledger_accounts_on_ledger_account_id"
  add_index "supplier_ledger_accounts", ["supplier_id", "ledger_account_id"], :name => "index_supplier_ledger_accounts_unique", :unique => true
  add_index "supplier_ledger_accounts", ["supplier_id"], :name => "index_supplier_ledger_accounts_on_supplier_id"

  create_table "supplier_payments", :force => true do |t|
    t.integer  "supplier_id"
    t.integer  "supplier_invoice_id"
    t.integer  "payment_method_id"
    t.date     "payment_date"
    t.decimal  "amount",                       :precision => 13, :scale => 4, :default => 0.0, :null => false
    t.string   "remarks"
    t.integer  "approver_id"
    t.datetime "created_at",                                                                   :null => false
    t.datetime "updated_at",                                                                   :null => false
    t.string   "payment_no"
    t.integer  "organization_id"
    t.integer  "supplier_invoice_approval_id"
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "supplier_payments", ["approver_id"], :name => "index_supplier_payments_on_approver_id"
  add_index "supplier_payments", ["organization_id", "payment_no"], :name => "index_supplier_payments_on_organization_id_and_payment_no", :unique => true
  add_index "supplier_payments", ["organization_id"], :name => "index_supplier_payments_on_organization_id"
  add_index "supplier_payments", ["payment_method_id"], :name => "index_supplier_payments_on_payment_method_id"
  add_index "supplier_payments", ["payment_no"], :name => "index_supplier_payments_on_payment_no"
  add_index "supplier_payments", ["supplier_id"], :name => "index_supplier_payments_on_supplier_id"
  add_index "supplier_payments", ["supplier_invoice_approval_id"], :name => "index_supplier_payments_on_supplier_invoice_approval_id"
  add_index "supplier_payments", ["supplier_invoice_id"], :name => "index_supplier_payments_on_supplier_invoice_id"

  create_table "suppliers", :force => true do |t|
    t.string   "name"
    t.string   "supplier_code"
    t.string   "fiscal_id"
    t.datetime "created_at",                                                           :null => false
    t.datetime "updated_at",                                                           :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
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
    t.integer  "region_id"
    t.integer  "country_id"
    t.integer  "payment_method_id"
    t.decimal  "discount_rate",       :precision => 6,  :scale => 2, :default => 0.0,  :null => false
    t.boolean  "active",                                             :default => true, :null => false
    t.integer  "max_orders_count",                                   :default => 0
    t.decimal  "max_orders_sum",      :precision => 13, :scale => 4, :default => 0.0,  :null => false
    t.string   "contract_number"
    t.string   "remarks"
    t.integer  "entity_id"
    t.integer  "organization_id"
    t.boolean  "is_contact"
    t.integer  "shared_contact_id"
    t.boolean  "order_authorization"
    t.integer  "ledger_account_id"
    t.decimal  "free_shipping_sum",   :precision => 13, :scale => 4, :default => 0.0,  :null => false
    t.decimal  "withholding_rate",    :precision => 6,  :scale => 2, :default => 0.0,  :null => false
    t.integer  "withholding_type_id"
  end

  add_index "suppliers", ["active"], :name => "index_suppliers_on_active"
  add_index "suppliers", ["cellular"], :name => "index_suppliers_on_cellular"
  add_index "suppliers", ["contract_number"], :name => "index_suppliers_on_contract_number"
  add_index "suppliers", ["country_id"], :name => "index_suppliers_on_country_id"
  add_index "suppliers", ["email"], :name => "index_suppliers_on_email"
  add_index "suppliers", ["entity_id"], :name => "index_suppliers_on_entity_id"
  add_index "suppliers", ["fax"], :name => "index_suppliers_on_fax"
  add_index "suppliers", ["fiscal_id"], :name => "index_suppliers_on_fiscal_id"
  add_index "suppliers", ["ledger_account_id"], :name => "index_suppliers_on_ledger_account_id"
  add_index "suppliers", ["name"], :name => "index_suppliers_on_name"
  add_index "suppliers", ["organization_id", "fiscal_id"], :name => "index_suppliers_on_organization_id_and_fiscal_id", :unique => true
  add_index "suppliers", ["organization_id", "supplier_code"], :name => "index_suppliers_on_organization_id_and_supplier_code", :unique => true
  add_index "suppliers", ["organization_id"], :name => "index_suppliers_on_organization_id"
  add_index "suppliers", ["payment_method_id"], :name => "index_suppliers_on_payment_method_id"
  add_index "suppliers", ["phone"], :name => "index_suppliers_on_phone"
  add_index "suppliers", ["province_id"], :name => "index_suppliers_on_province_id"
  add_index "suppliers", ["region_id"], :name => "index_suppliers_on_region_id"
  add_index "suppliers", ["shared_contact_id"], :name => "index_suppliers_on_shared_contact_id"
  add_index "suppliers", ["street_name"], :name => "index_suppliers_on_street_name"
  add_index "suppliers", ["street_type_id"], :name => "index_suppliers_on_street_type_id"
  add_index "suppliers", ["supplier_code"], :name => "index_suppliers_on_supplier_code"
  add_index "suppliers", ["town_id"], :name => "index_suppliers_on_town_id"
  add_index "suppliers", ["withholding_type_id"], :name => "index_suppliers_on_withholding_type_id"
  add_index "suppliers", ["zipcode_id"], :name => "index_suppliers_on_zipcode_id"

  create_table "suppliers_activities", :id => false, :force => true do |t|
    t.integer "supplier_id"
    t.integer "activity_id"
  end

  add_index "suppliers_activities", ["supplier_id", "activity_id"], :name => "index_suppliers_activities_on_supplier_id_and_activity_id"

  create_table "tariff_scheme_items", :force => true do |t|
    t.integer  "tariff_scheme_id"
    t.integer  "tariff_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "tariff_scheme_items", ["tariff_id"], :name => "index_tariff_scheme_items_on_tariff_id"
  add_index "tariff_scheme_items", ["tariff_scheme_id"], :name => "index_tariff_scheme_items_on_tariff_scheme_id"

  create_table "tariff_schemes", :force => true do |t|
    t.integer  "project_id"
    t.string   "name"
    t.integer  "tariff_type_id"
    t.date     "starting_at"
    t.date     "ending_at"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.integer  "use_id"
  end

  add_index "tariff_schemes", ["project_id"], :name => "index_tariff_schemes_on_project_id"
  add_index "tariff_schemes", ["tariff_type_id"], :name => "index_tariff_schemes_on_tariff_type_id"
  add_index "tariff_schemes", ["use_id"], :name => "index_tariff_schemes_on_use_id"

  create_table "tariff_types", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.integer  "use_id"
  end

  add_index "tariff_types", ["code"], :name => "index_tariff_types_on_code", :unique => true
  add_index "tariff_types", ["use_id"], :name => "index_tariff_types_on_use_id"

  create_table "tariffs", :force => true do |t|
    t.integer  "tariff_scheme_id"
    t.integer  "billable_item_id"
    t.integer  "tariff_type_id"
    t.integer  "caliber_id"
    t.integer  "billing_frequency_id"
    t.decimal  "fixed_fee",                     :precision => 12, :scale => 6, :default => 0.0, :null => false
    t.decimal  "variable_fee",                  :precision => 12, :scale => 6, :default => 0.0, :null => false
    t.decimal  "percentage_fee",                :precision => 6,  :scale => 2, :default => 0.0, :null => false
    t.string   "percentage_applicable_formula"
    t.integer  "block1_limit"
    t.integer  "block2_limit"
    t.integer  "block3_limit"
    t.integer  "block4_limit"
    t.integer  "block5_limit"
    t.integer  "block6_limit"
    t.integer  "block7_limit"
    t.integer  "block8_limit"
    t.decimal  "block1_fee",                    :precision => 12, :scale => 6, :default => 0.0, :null => false
    t.decimal  "block2_fee",                    :precision => 12, :scale => 6, :default => 0.0, :null => false
    t.decimal  "block3_fee",                    :precision => 12, :scale => 6, :default => 0.0, :null => false
    t.decimal  "block4_fee",                    :precision => 12, :scale => 6, :default => 0.0, :null => false
    t.decimal  "block5_fee",                    :precision => 12, :scale => 6, :default => 0.0, :null => false
    t.decimal  "block6_fee",                    :precision => 12, :scale => 6, :default => 0.0, :null => false
    t.decimal  "block7_fee",                    :precision => 12, :scale => 6, :default => 0.0, :null => false
    t.decimal  "block8_fee",                    :precision => 12, :scale => 6, :default => 0.0, :null => false
    t.decimal  "discount_pct_f",                :precision => 6,  :scale => 2, :default => 0.0, :null => false
    t.decimal  "discount_pct_v",                :precision => 6,  :scale => 2, :default => 0.0, :null => false
    t.decimal  "discount_pct_p",                :precision => 6,  :scale => 2, :default => 0.0, :null => false
    t.decimal  "discount_pct_b",                :precision => 6,  :scale => 2, :default => 0.0, :null => false
    t.integer  "tax_type_f_id"
    t.integer  "tax_type_v_id"
    t.integer  "tax_type_p_id"
    t.integer  "tax_type_b_id"
    t.datetime "created_at",                                                                    :null => false
    t.datetime "updated_at",                                                                    :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.date     "starting_at"
    t.date     "ending_at"
    t.decimal  "percentage_fixed_fee",          :precision => 6,  :scale => 2, :default => 0.0, :null => false
  end

  add_index "tariffs", ["billable_item_id"], :name => "index_tariffs_on_billable_item_id"
  add_index "tariffs", ["billing_frequency_id"], :name => "index_tariffs_on_billing_frequency_id"
  add_index "tariffs", ["caliber_id"], :name => "index_tariffs_on_caliber_id"
  add_index "tariffs", ["tariff_scheme_id", "billable_item_id", "tariff_type_id", "caliber_id", "billing_frequency_id"], :name => "index_tariffs_unique", :unique => true
  add_index "tariffs", ["tariff_scheme_id"], :name => "index_tariffs_on_tariff_scheme_id"
  add_index "tariffs", ["tariff_type_id"], :name => "index_tariffs_on_tariff_type_id"
  add_index "tariffs", ["tax_type_b_id"], :name => "index_tariffs_on_tax_type_b_id"
  add_index "tariffs", ["tax_type_f_id"], :name => "index_tariffs_on_tax_type_f_id"
  add_index "tariffs", ["tax_type_p_id"], :name => "index_tariffs_on_tax_type_p_id"
  add_index "tariffs", ["tax_type_v_id"], :name => "index_tariffs_on_tax_type_v_id"

  create_table "tax_type_ledger_accounts", :force => true do |t|
    t.integer  "tax_type_id"
    t.integer  "input_ledger_account_id"
    t.integer  "output_ledger_account_id"
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.integer  "company_id"
  end

  add_index "tax_type_ledger_accounts", ["company_id"], :name => "index_tax_type_ledger_accounts_on_company_id"
  add_index "tax_type_ledger_accounts", ["input_ledger_account_id"], :name => "index_tax_type_ledger_accounts_on_input_ledger_account_id"
  add_index "tax_type_ledger_accounts", ["output_ledger_account_id"], :name => "index_tax_type_ledger_accounts_on_output_ledger_account_id"
  add_index "tax_type_ledger_accounts", ["tax_type_id", "input_ledger_account_id", "output_ledger_account_id"], :name => "index_tax_type_ledger_accounts_unique", :unique => true
  add_index "tax_type_ledger_accounts", ["tax_type_id"], :name => "index_tax_type_ledger_accounts_on_tax_type_id"

  create_table "tax_types", :force => true do |t|
    t.string   "description"
    t.decimal  "tax",                      :precision => 6, :scale => 2, :default => 0.0, :null => false
    t.datetime "created_at",                                                              :null => false
    t.datetime "updated_at",                                                              :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.date     "expiration"
    t.integer  "input_ledger_account_id"
    t.integer  "output_ledger_account_id"
  end

  add_index "tax_types", ["input_ledger_account_id"], :name => "index_tax_types_on_input_ledger_account_id"
  add_index "tax_types", ["output_ledger_account_id"], :name => "index_tax_types_on_output_ledger_account_id"
  add_index "tax_types", ["tax"], :name => "index_tax_types_on_tax"

  create_table "technicians", :force => true do |t|
    t.string   "name"
    t.integer  "user_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.integer  "organization_id"
  end

  add_index "technicians", ["name"], :name => "index_technicians_on_name"
  add_index "technicians", ["organization_id", "user_id"], :name => "index_technicians_on_organization_id_and_user_id", :unique => true
  add_index "technicians", ["organization_id"], :name => "index_technicians_on_organization_id"
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
    t.string   "ticket_message",          :limit => 1000
    t.integer  "ticket_status_id"
    t.integer  "technician_id"
    t.datetime "assign_at"
    t.datetime "status_changed_at"
    t.string   "status_changed_message"
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.integer  "office_id"
    t.string   "source_ip"
    t.string   "hd_email"
    t.integer  "organization_id"
    t.integer  "cc_id"
  end

  add_index "tickets", ["assign_at"], :name => "index_tickets_on_assign_at"
  add_index "tickets", ["created_at"], :name => "index_tickets_on_created_at"
  add_index "tickets", ["created_by"], :name => "index_tickets_on_created_by"
  add_index "tickets", ["office_id"], :name => "index_tickets_on_office_id"
  add_index "tickets", ["organization_id"], :name => "index_tickets_on_organization_id"
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

  create_table "tools", :force => true do |t|
    t.integer  "organization_id"
    t.integer  "company_id"
    t.integer  "office_id"
    t.integer  "product_id"
    t.string   "name"
    t.string   "serial_no"
    t.string   "brand"
    t.string   "model"
    t.decimal  "cost",               :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.datetime "created_at",                                                         :null => false
    t.datetime "updated_at",                                                         :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
  end

  add_index "tools", ["company_id"], :name => "index_tools_on_company_id"
  add_index "tools", ["office_id"], :name => "index_tools_on_office_id"
  add_index "tools", ["organization_id", "company_id", "office_id", "serial_no"], :name => "index_tools_on_organization_and_serial", :unique => true
  add_index "tools", ["organization_id"], :name => "index_tools_on_organization_id"
  add_index "tools", ["product_id"], :name => "index_tools_on_product_id"
  add_index "tools", ["serial_no"], :name => "index_tools_on_serial_no"

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
    t.string   "email",                  :default => "",   :null => false
    t.string   "encrypted_password",     :default => "",   :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
    t.string   "name",                   :default => "",   :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.boolean  "real_email",             :default => true
    t.string   "authentication_token"
  end

  add_index "users", ["authentication_token"], :name => "index_users_on_authentication_token", :unique => true
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

  create_table "users_projects", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "project_id"
  end

  add_index "users_projects", ["user_id", "project_id"], :name => "index_users_projects_on_user_id_and_project_id"

  create_table "users_roles", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  add_index "users_roles", ["user_id", "role_id"], :name => "index_users_roles_on_user_id_and_role_id"

  create_table "uses", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "uses", ["code"], :name => "index_uses_on_code", :unique => true

  create_table "vehicles", :force => true do |t|
    t.integer  "organization_id"
    t.integer  "company_id"
    t.integer  "office_id"
    t.integer  "product_id"
    t.string   "name"
    t.string   "registration"
    t.string   "brand"
    t.string   "model"
    t.decimal  "cost",               :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.datetime "created_at",                                                         :null => false
    t.datetime "updated_at",                                                         :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
  end

  add_index "vehicles", ["company_id"], :name => "index_vehicles_on_company_id"
  add_index "vehicles", ["office_id"], :name => "index_vehicles_on_office_id"
  add_index "vehicles", ["organization_id", "company_id", "office_id", "registration"], :name => "index_vehicles_on_organization_and_registration", :unique => true
  add_index "vehicles", ["organization_id"], :name => "index_vehicles_on_organization_id"
  add_index "vehicles", ["product_id"], :name => "index_vehicles_on_product_id"
  add_index "vehicles", ["registration"], :name => "index_vehicles_on_registration"

  create_table "versions", :force => true do |t|
    t.string   "item_type",  :null => false
    t.integer  "item_id",    :null => false
    t.string   "event",      :null => false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], :name => "index_versions_on_item_type_and_item_id"

  create_table "water_connection_contracts", :force => true do |t|
    t.integer  "contracting_request_id"
    t.integer  "water_connection_type_id"
    t.date     "contract_date"
    t.integer  "client_id"
    t.integer  "work_order_id"
    t.integer  "sale_offer_id"
    t.integer  "tariff_id"
    t.integer  "bill_id"
    t.string   "remarks"
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "water_connection_contracts", ["bill_id"], :name => "index_water_connection_contracts_on_bill_id"
  add_index "water_connection_contracts", ["client_id"], :name => "index_water_connection_contracts_on_client_id"
  add_index "water_connection_contracts", ["contracting_request_id"], :name => "index_water_connection_contracts_on_contracting_request_id"
  add_index "water_connection_contracts", ["sale_offer_id"], :name => "index_water_connection_contracts_on_sale_offer_id"
  add_index "water_connection_contracts", ["tariff_id"], :name => "index_water_connection_contracts_on_tariff_id"
  add_index "water_connection_contracts", ["water_connection_type_id"], :name => "index_water_connection_contracts_on_water_connection_type_id"
  add_index "water_connection_contracts", ["work_order_id"], :name => "index_water_connection_contracts_on_work_order_id"

  create_table "water_connection_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  create_table "water_connections", :force => true do |t|
    t.integer  "water_connection_type_id"
    t.string   "code"
    t.string   "name"
    t.string   "gis_id"
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "water_connections", ["gis_id"], :name => "index_water_connections_on_gis_id"
  add_index "water_connections", ["water_connection_type_id"], :name => "index_water_connections_on_water_connection_type_id"

  create_table "water_supply_contracts", :force => true do |t|
    t.integer  "contracting_request_id"
    t.integer  "client_id"
    t.integer  "subscriber_id"
    t.integer  "reading_route_id"
    t.integer  "work_order_id"
    t.integer  "meter_id"
    t.integer  "tariff_scheme_id"
    t.integer  "bill_id"
    t.integer  "caliber_id"
    t.date     "contract_date"
    t.integer  "reading_sequence"
    t.string   "cadastral_reference"
    t.string   "gis_id"
    t.integer  "endowments",             :limit => 2, :default => 0
    t.integer  "inhabitants",            :limit => 2, :default => 0
    t.date     "installation_date"
    t.integer  "installation_index"
    t.string   "remarks"
    t.datetime "created_at",                                         :null => false
    t.datetime "updated_at",                                         :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.integer  "use_id"
    t.integer  "tariff_type_id"
    t.integer  "unsubscribe_bill_id"
    t.integer  "bailback_bill_id"
    t.string   "max_pressure"
    t.string   "min_pressure"
    t.string   "contract_term"
  end

  add_index "water_supply_contracts", ["bailback_bill_id"], :name => "index_water_supply_contracts_on_bailback_bill_id"
  add_index "water_supply_contracts", ["bill_id"], :name => "index_water_supply_contracts_on_bill_id"
  add_index "water_supply_contracts", ["caliber_id"], :name => "index_water_supply_contracts_on_caliber_id"
  add_index "water_supply_contracts", ["client_id"], :name => "index_water_supply_contracts_on_client_id"
  add_index "water_supply_contracts", ["contracting_request_id"], :name => "index_water_supply_contracts_on_contracting_request_id"
  add_index "water_supply_contracts", ["meter_id"], :name => "index_water_supply_contracts_on_meter_id"
  add_index "water_supply_contracts", ["reading_route_id"], :name => "index_water_supply_contracts_on_reading_route_id"
  add_index "water_supply_contracts", ["subscriber_id"], :name => "index_water_supply_contracts_on_subscriber_id"
  add_index "water_supply_contracts", ["tariff_scheme_id"], :name => "index_water_supply_contracts_on_tariff_scheme_id"
  add_index "water_supply_contracts", ["tariff_type_id"], :name => "index_water_supply_contracts_on_tariff_type_id"
  add_index "water_supply_contracts", ["unsubscribe_bill_id"], :name => "index_water_supply_contracts_on_unsubscribe_bill_id"
  add_index "water_supply_contracts", ["use_id"], :name => "index_water_supply_contracts_on_use_id"
  add_index "water_supply_contracts", ["work_order_id"], :name => "index_water_supply_contracts_on_work_order_id"

  create_table "withholding_types", :force => true do |t|
    t.string   "description"
    t.decimal  "tax",                     :precision => 6, :scale => 2, :default => 0.0, :null => false
    t.date     "expiration"
    t.datetime "created_at",                                                             :null => false
    t.datetime "updated_at",                                                             :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.string   "ledger_account_app_code"
  end

  add_index "withholding_types", ["tax"], :name => "index_withholding_types_on_tax"

  create_table "work_order_areas", :force => true do |t|
    t.string   "name"
    t.integer  "organization_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "work_order_areas", ["organization_id"], :name => "index_work_order_areas_on_organization_id"

  create_table "work_order_items", :force => true do |t|
    t.integer  "work_order_id"
    t.integer  "product_id"
    t.string   "description"
    t.decimal  "quantity",              :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.decimal  "cost",                  :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.decimal  "price",                 :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.integer  "tax_type_id"
    t.integer  "store_id"
    t.datetime "created_at",                                                            :null => false
    t.datetime "updated_at",                                                            :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.integer  "charge_account_id"
    t.integer  "delivery_note_item_id"
  end

  add_index "work_order_items", ["charge_account_id"], :name => "index_work_order_items_on_charge_account_id"
  add_index "work_order_items", ["delivery_note_item_id"], :name => "index_work_order_items_on_delivery_note_item_id"
  add_index "work_order_items", ["description"], :name => "index_work_order_items_on_description"
  add_index "work_order_items", ["product_id"], :name => "index_work_order_items_on_product_id"
  add_index "work_order_items", ["store_id"], :name => "index_work_order_items_on_store_id"
  add_index "work_order_items", ["tax_type_id"], :name => "index_work_order_items_on_tax_type_id"
  add_index "work_order_items", ["work_order_id"], :name => "index_work_order_items_on_work_order_id"

  create_table "work_order_labors", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.integer  "organization_id"
    t.integer  "work_order_type_id"
    t.boolean  "subscriber_meter",   :default => false
  end

  add_index "work_order_labors", ["organization_id"], :name => "index_work_order_labors_on_organization_id"
  add_index "work_order_labors", ["work_order_type_id"], :name => "index_work_order_labors_on_work_order_type_id"

  create_table "work_order_statuses", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  create_table "work_order_subcontractors", :force => true do |t|
    t.integer  "work_order_id"
    t.integer  "supplier_id"
    t.integer  "purchase_order_id"
    t.decimal  "enforcement_pct",   :precision => 7, :scale => 2, :default => 0.0, :null => false
    t.datetime "created_at",                                                       :null => false
    t.datetime "updated_at",                                                       :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.integer  "charge_account_id"
  end

  add_index "work_order_subcontractors", ["charge_account_id"], :name => "index_work_order_subcontractors_on_charge_account_id"
  add_index "work_order_subcontractors", ["purchase_order_id"], :name => "index_work_order_subcontractors_on_purchase_order_id"
  add_index "work_order_subcontractors", ["supplier_id"], :name => "index_work_order_subcontractors_on_supplier_id"
  add_index "work_order_subcontractors", ["work_order_id"], :name => "index_work_order_subcontractors_on_work_order_id"

  create_table "work_order_tools", :force => true do |t|
    t.integer  "work_order_id"
    t.integer  "tool_id"
    t.decimal  "minutes",           :precision => 7,  :scale => 2, :default => 0.0, :null => false
    t.decimal  "cost",              :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.datetime "created_at",                                                        :null => false
    t.datetime "updated_at",                                                        :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.integer  "charge_account_id"
  end

  add_index "work_order_tools", ["charge_account_id"], :name => "index_work_order_tools_on_charge_account_id"
  add_index "work_order_tools", ["tool_id"], :name => "index_work_order_tools_on_tool_id"
  add_index "work_order_tools", ["work_order_id"], :name => "index_work_order_tools_on_work_order_id"

  create_table "work_order_type_accounts", :force => true do |t|
    t.integer  "work_order_type_id"
    t.integer  "project_id"
    t.integer  "charge_account_id"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "work_order_type_accounts", ["charge_account_id"], :name => "index_work_order_type_accounts_on_charge_account_id"
  add_index "work_order_type_accounts", ["project_id"], :name => "index_work_order_type_accounts_on_project_id"
  add_index "work_order_type_accounts", ["work_order_type_id", "project_id", "charge_account_id"], :name => "index_wo_type_accounts_unique", :unique => true
  add_index "work_order_type_accounts", ["work_order_type_id"], :name => "index_work_order_type_accounts_on_work_order_type_id"

  create_table "work_order_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.integer  "organization_id"
    t.integer  "charge_account_id"
    t.integer  "work_order_area_id"
    t.boolean  "subscriber_meter",   :default => false
  end

  add_index "work_order_types", ["charge_account_id"], :name => "index_work_order_types_on_charge_account_id"
  add_index "work_order_types", ["organization_id"], :name => "index_work_order_types_on_organization_id"
  add_index "work_order_types", ["work_order_area_id"], :name => "index_work_order_types_on_work_order_area_id"

  create_table "work_order_vehicles", :force => true do |t|
    t.integer  "work_order_id"
    t.integer  "vehicle_id"
    t.decimal  "distance",          :precision => 7,  :scale => 2, :default => 0.0, :null => false
    t.decimal  "cost",              :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.datetime "created_at",                                                        :null => false
    t.datetime "updated_at",                                                        :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.integer  "charge_account_id"
  end

  add_index "work_order_vehicles", ["charge_account_id"], :name => "index_work_order_vehicles_on_charge_account_id"
  add_index "work_order_vehicles", ["vehicle_id"], :name => "index_work_order_vehicles_on_vehicle_id"
  add_index "work_order_vehicles", ["work_order_id"], :name => "index_work_order_vehicles_on_work_order_id"

  create_table "work_order_workers", :force => true do |t|
    t.integer  "work_order_id"
    t.integer  "worker_id"
    t.decimal  "hours",             :precision => 9,  :scale => 4, :default => 0.0, :null => false
    t.decimal  "cost",              :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.datetime "created_at",                                                        :null => false
    t.datetime "updated_at",                                                        :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.integer  "charge_account_id"
  end

  add_index "work_order_workers", ["charge_account_id"], :name => "index_work_order_workers_on_charge_account_id"
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
    t.datetime "created_at",                                                                         :null => false
    t.datetime "updated_at",                                                                         :null => false
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
    t.integer  "subscriber_id"
    t.string   "incidences"
    t.integer  "meter_id"
    t.string   "meter_code"
    t.integer  "meter_model_id"
    t.integer  "caliber_id"
    t.integer  "meter_owner_id"
    t.integer  "meter_location_id"
    t.integer  "last_reading_id"
    t.datetime "current_reading_date"
    t.integer  "current_reading_index"
    t.boolean  "por_affected"
    t.integer  "work_order_area_id"
    t.integer  "infrastructure_id"
    t.integer  "hours_type",            :limit => 2,                                :default => 0,   :null => false
    t.decimal  "totals",                             :precision => 13, :scale => 4, :default => 0.0, :null => false
    t.decimal  "this_costs",                         :precision => 13, :scale => 4, :default => 0.0, :null => false
    t.decimal  "with_suborder_costs",                :precision => 13, :scale => 4, :default => 0.0, :null => false
  end

  add_index "work_orders", ["area_id"], :name => "index_work_orders_on_area_id"
  add_index "work_orders", ["caliber_id"], :name => "index_work_orders_on_caliber_id"
  add_index "work_orders", ["charge_account_id"], :name => "index_work_orders_on_charge_account_id"
  add_index "work_orders", ["client_id"], :name => "index_work_orders_on_client_id"
  add_index "work_orders", ["completed_at"], :name => "index_work_orders_on_completed_at"
  add_index "work_orders", ["in_charge_id"], :name => "index_work_orders_on_in_charge_id"
  add_index "work_orders", ["infrastructure_id"], :name => "index_work_orders_on_infrastructure_id"
  add_index "work_orders", ["last_reading_id"], :name => "index_work_orders_on_last_reading_id"
  add_index "work_orders", ["master_order_id"], :name => "index_work_orders_on_master_order_id"
  add_index "work_orders", ["meter_code"], :name => "index_work_orders_on_meter_code"
  add_index "work_orders", ["meter_id"], :name => "index_work_orders_on_meter_id"
  add_index "work_orders", ["meter_location_id"], :name => "index_work_orders_on_meter_location_id"
  add_index "work_orders", ["meter_model_id"], :name => "index_work_orders_on_meter_model_id"
  add_index "work_orders", ["meter_owner_id"], :name => "index_work_orders_on_meter_owner_id"
  add_index "work_orders", ["order_no"], :name => "index_work_orders_on_order_no"
  add_index "work_orders", ["organization_id", "order_no"], :name => "index_work_orders_on_organization_id_and_order_no", :unique => true
  add_index "work_orders", ["organization_id"], :name => "index_work_orders_on_organization_id"
  add_index "work_orders", ["project_id"], :name => "index_work_orders_on_project_id"
  add_index "work_orders", ["started_at"], :name => "index_work_orders_on_started_at"
  add_index "work_orders", ["store_id"], :name => "index_work_orders_on_store_id"
  add_index "work_orders", ["subscriber_id"], :name => "index_work_orders_on_subscriber_id"
  add_index "work_orders", ["work_order_area_id"], :name => "index_work_orders_on_work_order_area_id"
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
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.integer  "organization_id"
  end

  add_index "worker_types", ["organization_id"], :name => "index_worker_types_on_organization_id"

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
    t.string   "floor"
    t.string   "floor_office"
    t.integer  "zipcode_id"
    t.integer  "town_id"
    t.integer  "province_id"
    t.string   "own_phone"
    t.string   "own_cellular"
    t.string   "email"
    t.datetime "created_at",                                                                 :null => false
    t.datetime "updated_at",                                                                 :null => false
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
    t.decimal  "gross_salary",              :precision => 12, :scale => 4, :default => 0.0,  :null => false
    t.decimal  "variable_salary",           :precision => 12, :scale => 4, :default => 0.0,  :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.string   "remarks"
    t.decimal  "social_security_cost",      :precision => 12, :scale => 4, :default => 0.0,  :null => false
    t.string   "education"
    t.integer  "sex_id"
    t.integer  "insurance_id"
    t.integer  "organization_id"
    t.boolean  "is_contact"
    t.boolean  "real_email",                                               :default => true
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
  add_index "workers", ["organization_id", "fiscal_id"], :name => "index_workers_on_organization_id_and_fiscal_id", :unique => true
  add_index "workers", ["organization_id", "worker_code"], :name => "index_workers_on_organization_id_and_worker_code"
  add_index "workers", ["organization_id"], :name => "index_workers_on_organization_id"
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

  create_table "zone_notifications", :force => true do |t|
    t.integer  "zone_id"
    t.integer  "notification_id"
    t.integer  "user_id"
    t.integer  "role",            :limit => 2
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
  end

  add_index "zone_notifications", ["notification_id"], :name => "index_zone_notifications_on_notification_id"
  add_index "zone_notifications", ["role"], :name => "index_zone_notifications_on_role"
  add_index "zone_notifications", ["user_id"], :name => "index_zone_notifications_on_user_id"
  add_index "zone_notifications", ["zone_id"], :name => "index_zone_notifications_on_zone_id"

  create_table "zones", :force => true do |t|
    t.string   "name"
    t.decimal  "max_order_total", :precision => 13, :scale => 4, :default => 0.0, :null => false
    t.decimal  "decimal",         :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.decimal  "max_order_price", :precision => 12, :scale => 4, :default => 0.0, :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "created_at",                                                      :null => false
    t.datetime "updated_at",                                                      :null => false
    t.integer  "organization_id"
    t.integer  "worker_id"
  end

  add_index "zones", ["organization_id"], :name => "index_zones_on_organization_id"
  add_index "zones", ["worker_id"], :name => "index_zones_on_worker_id"

end
