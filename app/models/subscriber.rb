class Subscriber < ActiveRecord::Base
  include ModelsModule

  # CONSTANTS
  # landlord_tenant:
  LANDLORD = 0
  TENANT = 1
  LANDLORD_TENANT = { I18n.t('activerecord.attributes.subscriber.landlord') => 0, I18n.t('activerecord.attributes.subscriber.tenant') => 1}

  belongs_to :client, :counter_cache => true
  belongs_to :office
  belongs_to :center
  belongs_to :street_directory
  belongs_to :zipcode
  belongs_to :service_point
  belongs_to :tariff_scheme
  belongs_to :billing_frequency
  belongs_to :meter
  belongs_to :reading_route
  belongs_to :contracting_request
  belongs_to :use
  belongs_to :postal_street_directory, :class_name => 'StreetDirectory', :foreign_key => 'postal_street_directory_id'
  belongs_to :postal_street_type, :class_name => 'StreetType', :foreign_key => 'postal_street_type_id'
  belongs_to :postal_zipcode, :class_name => 'Zipcode', :foreign_key => 'postal_zipcode_id'
  belongs_to :postal_town, :class_name => 'Town', :foreign_key => 'postal_town_id'
  belongs_to :postal_province, :class_name => 'Province', :foreign_key => 'postal_province_id'
  belongs_to :postal_region, :class_name => 'Region', :foreign_key => 'postal_region_id'
  belongs_to :postal_country, :class_name => 'Country', :foreign_key => 'postal_country_id'
  attr_accessible :company, :first_name, :fiscal_id, :last_name, :subscriber_code,
                  :starting_at, :ending_at, :created_by, :updated_by,
                  :client_id, :office_id, :center_id, :street_directory_id, :street_number,
                  :building, :floor, :floor_office, :zipcode_id, :phone, :fax, :cellular, :email,
                  :service_point_id, :active, :tariff_scheme_id, :billing_frequency_id, :meter_id,
                  :reading_route_id, :reading_sequence, :reading_variant, :contracting_request_id, :use_id,
                  :remarks, :cadastral_reference, :gis_id, :endowments, :inhabitants, :km, :gis_id_wc,
                  :pub_record, :m2, :equiv_dwelling, :deposit, :old_code, :client_town_id, :client_zipcode_id,
                  :client_province_id, :client_region_id, :client_street_directory_id,
                  :client_street_name, :client_street_number, :client_street_type_id,
                  :readings_attributes, :meter_details_attributes, :postal_last_name, :postal_first_name, :postal_company,
                  :postal_street_directory_id, :postal_street_type_id, :postal_street_name, :postal_street_number,
                  :postal_building, :postal_floor, :postal_floor_office, :postal_zipcode_id, :postal_town_id,
                  :postal_province_id, :postal_region_id, :postal_country_id, :non_billable,
                  :sub_use, :pub_entity, :landlord_tenant, :consumption_estimated_balance,
                  :consumption_estimated_balance_init_at, :consumption_estimated_balance_reset_at,
                  :inhabitants_ending_at

  attr_accessor :reading_index_add, :reading_date_add

  delegate :full_code, :to => :client, :allow_nil => true, :prefix => true
  delegate :to_full_label, :to => :service_point, :allow_nil => true, :prefix => true
  delegate :zipcode, :to => :zipcode, :allow_nil => true, :prefix => true
  delegate :alt_code, :to => :street_directory, :allow_nil => true, :prefix => true
  delegate :name, :to => :center, :allow_nil => true, :prefix => true
  delegate :full_no, :to => :water_supply_contract, :allow_nil => true, :prefix => true
  delegate :name, :to => :tariff_scheme, :allow_nil => true, :prefix => true
  delegate :name, :to => :billing_frequency, :allow_nil => true, :prefix => true
  delegate :name, :to => :use, :allow_nil => true, :prefix => true
  delegate :meter_code, :to => :meter, :allow_nil => true, :prefix => true
  delegate :model_full_name, :to => :meter, :allow_nil => true, :prefix => true
  delegate :meter_model_id, :to => :meter, :allow_nil => true, :prefix => true
  delegate :caliber_caliber, :to => :meter, :allow_nil => true, :prefix => true
  delegate :caliber_id, :to => :meter, :allow_nil => true, :prefix => true
  delegate :to_label, :to => :reading_route, :allow_nil => true, :prefix => true

  has_many :client_bank_accounts, dependent: :destroy
  has_many :work_orders
  has_many :meter_details
  has_one :contracting_request
  has_one :water_supply_contract
  has_many :contracted_tariffs, through: :water_supply_contract
  has_one :subscriber_supply_address
  has_one :subscriber_filiation
  has_many :readings
  has_many :pre_readings
  has_many :pre_bills
  has_many :bills
  has_many :invoices, through: :bills
  has_many :client_payments
  has_many :subscriber_tariffs
  has_many :tariffs, through: :subscriber_tariffs
  has_many :cancelled_invoices
  has_many :active_invoices
  has_many :active_supply_invoices
  has_many :invoice_debts
  has_many :invoice_current_debts
  has_many :invoice_bills
  has_many :invoice_credits
  has_many :invoice_rebills
  has_many :subscriber_estimation_balances
  has_many :subscriber_annotations

  # Nested attributes
  accepts_nested_attributes_for :readings
  accepts_nested_attributes_for :meter_details

  has_paper_trail

  validates :client,            :presence => true
  validates :office,            :presence => true
  validates :center,            :presence => true
  validates :street_directory,  :presence => true
  validates :subscriber_code,   :presence => true,
                                :length => { :is => 11 },
                                :uniqueness => { :scope => :office_id },
                                :format => { with: /\A\d+\Z/, message: :code_invalid }
  validates :fiscal_id,         :presence => true,
                                :length => { :minimum => 8 }
  validates :zipcode,           :presence => true
  validates :starting_at,       :presence => true
  validates :first_name,        :presence => true, :if => "company.blank?"
  validates :last_name,         :presence => true, :if => "company.blank?"

  # Scopes
  scope :by_code, -> { order('subscribers.subscriber_code') }
  scope :by_code_desc, -> { order('subscribers.subscriber_code desc') }
  scope :by_reading_sequence, -> { order(:reading_route_id, :reading_sequence, :reading_variant, :subscriber_code) }
  #
  scope :belongs_to_office, -> office { where("office_id = ?", office).by_code }
  scope :actives, -> { where(active: true).by_code }
  scope :active_by_office, -> office { where(active: true, office_id: office).by_code }
  scope :availables, -> { where("ending_at IS NULL OR ending_at >= ?", Date.today)}
  scope :unavailables, -> { where("NOT ending_at IS NULL OR active = false") }
  scope :activated, -> { where("(ending_at IS NULL OR ending_at >= ?) AND active = true", Date.today) }
  scope :deactivated, -> { where("(ending_at IS NULL OR ending_at >= ?) AND active = false AND meter_id IS NULL", Date.today) }
  scope :activated_by_office, -> office { where("((ending_at IS NULL OR ending_at >= ?) AND active = true) AND office_id = ?", Date.today, office).by_code }
  scope :availables_by_office, -> office { where("(ending_at IS NULL OR ending_at >= ?) AND office_id = ?", Date.today, office).by_code }
  # generic where (eg. for Select2 from engines_controller)
  scope :g_where, -> w {
    select("id, active, fiscal_id, subscriber_code, first_name, last_name, company,
            CASE WHEN (ISNULL(subscribers.company) OR subscribers.company = '') THEN CONCAT(subscribers.last_name, ', ', subscribers.first_name) ELSE subscribers.company END full_name")
    .where(w).by_code
  }
  scope :g_where_h, -> h {
    select("id, active, fiscal_id, subscriber_code, first_name, last_name, company,
            CASE WHEN (ISNULL(subscribers.company) OR subscribers.company = '') THEN CONCAT(subscribers.last_name, ', ', subscribers.first_name) ELSE subscribers.company END full_name")
    .availables.by_code.having(h)
  }
  scope :g_where_oh, -> o, h {
    select("id, active, fiscal_id, subscriber_code, first_name, last_name, company,
            CASE WHEN (ISNULL(subscribers.company) OR subscribers.company = '') THEN CONCAT(subscribers.last_name, ', ', subscribers.first_name) ELSE subscribers.company END full_name")
    .availables_by_office(o).having(h)
  }
  scope :g_where_all_h, -> h {
    select("id, active, fiscal_id, subscriber_code, first_name, last_name, company,
            CASE WHEN (ISNULL(subscribers.company) OR subscribers.company = '') THEN CONCAT(subscribers.last_name, ', ', subscribers.first_name) ELSE subscribers.company END full_name")
    .by_code.having(h)
  }
  scope :g_where_all_oh, -> o, h {
    select("id, active, fiscal_id, subscriber_code, first_name, last_name, company,
            CASE WHEN (ISNULL(subscribers.company) OR subscribers.company = '') THEN CONCAT(subscribers.last_name, ', ', subscribers.first_name) ELSE subscribers.company END full_name")
    .belongs_to_office(o).having(h)
  }
  # *** For readings ***
  scope :with_meter, -> { where("((NOT meter_id IS NULL) AND meter_id >= 0)").by_reading_sequence }
  scope :activated_with_meter, -> { activated.with_meter.by_reading_sequence }
  scope :activated_by_routes, -> r { activated.where("reading_route_id IN (?)", r).by_reading_sequence }
  scope :activated_by_routes_with_meter, -> r {
    activated_with_meter.where("reading_route_id IN (?)", r).by_reading_sequence
  }
  scope :activated_by_centers_with_meter, -> c {
    activated_with_meter.where("center_id IN (?)", c).by_reading_sequence
  }
  scope :activated_by_centers_and_routes_with_meter, -> c, r {
    activated_with_meter.where("center_id IN (?) AND reading_route_id IN (?)", c, r).by_reading_sequence
  }
  # *** As a replacement for the .find(params[:id]), with joins  ***
  scope :find_with_joins, -> i {
    joins("INNER JOIN clients on subscribers.client_id=clients.id")
    .joins("INNER JOIN street_directories sub_sd on subscribers.street_directory_id=sub_sd.id")
    .joins("INNER JOIN street_types sub_st on sub_sd.street_type_id=sub_st.id")
    .joins("INNER JOIN towns sub_tn on sub_sd.town_id=sub_tn.id")
    .joins("INNER JOIN zipcodes on subscribers.zipcode_id=zipcodes.id")
    .joins("INNER JOIN centers on subscribers.center_id=centers.id")
    .joins("INNER JOIN towns cn_tn on centers.town_id=cn_tn.id")
    .joins("INNER JOIN provinces cn_pr on cn_tn.province_id=cn_pr.id")
    .joins("INNER JOIN regions cn_rn on cn_pr.region_id=cn_rn.id")
    .joins("INNER JOIN countries cn_co on cn_rn.country_id=cn_co.id")
    .joins("LEFT JOIN water_supply_contracts wsc on subscribers.id=wsc.subscriber_id")
    .joins("LEFT JOIN tariff_schemes on subscribers.tariff_scheme_id=tariff_schemes.id")
    .joins("LEFT JOIN service_points on subscribers.service_point_id=service_points.id")
    .joins("INNER JOIN street_directories sp_sd on service_points.street_directory_id=sp_sd.id")
    .joins("INNER JOIN street_types sp_st on sp_sd.street_type_id=sp_st.id")
    .joins("INNER JOIN towns sp_tn on sp_sd.town_id=sp_tn.id")
    .where(id: i)
    .select("subscribers.id id_,
             CASE WHEN (ISNULL(subscribers.company) OR subscribers.company = '') THEN CONCAT(subscribers.last_name, ', ', subscribers.first_name) ELSE subscribers.company END full_name_,
             subscribers.fiscal_id fiscal_id_,
             CASE WHEN ISNULL(subscribers.subscriber_code) THEN '' ELSE CONCAT(SUBSTR(subscribers.subscriber_code,1,4), '-', SUBSTR(subscribers.subscriber_code,5,7)) END full_code_,
             CASE WHEN ISNULL(clients.client_code) THEN '' ELSE CONCAT(SUBSTR(clients.client_code,1,4), '-', SUBSTR(clients.client_code,5,7)) END client_full_code_,
             subscribers.pub_entity pub_entity_,
             subscribers.starting_at starting_at_,
             subscribers.ending_at ending_at_,
             subscribers.active active_,
             subscribers.non_billable non_billable_,
             subscribers.deposit deposit_,
             CONCAT(sp_st.street_type_code, ' ', sp_sd.street_name, ' ', service_points.street_number, ' (', sp_tn.name, ')') service_point_to_full_label_,
             subscribers.cadastral_reference cadastral_reference_,
             subscribers.pub_record pub_record_,
             CONCAT(sub_st.street_type_code, ' ', sub_sd.street_name, ' ', subscribers.street_number, (CASE WHEN NOT ISNULL(subscribers.building) AND subscribers.building<>'' THEN CONCAT(', ', subscribers.building) ELSE '' END), (CASE WHEN NOT ISNULL(subscribers.floor) AND subscribers.floor<>'' THEN CONCAT(', ', subscribers.floor) ELSE '' END), (CASE WHEN NOT ISNULL(subscribers.floor_office) AND subscribers.floor_office<>'' THEN CONCAT(' ', subscribers.floor_office) ELSE '' END)) address_1_,
             zipcodes.zipcode zipcode_,
             sub_sd.alt_code street_directory_alt_code_,
             centers.name center_name_,
             cn_tn.name town_name_,
             cn_pr.name province_name_,
             cn_rn.name region_name_,
             cn_co.name country_name_,
             CASE WHEN NOT ISNULL(wsc.contract_no) THEN CONCAT(SUBSTR(wsc.contract_no,1,6), '-', SUBSTR(wsc.contract_no,7,2), '-', SUBSTR(wsc.contract_no,9,4), '-', SUBSTR(wsc.contract_no,13,6)) ELSE '' END water_supply_contract_full_no_,
             tariff_schemes.name tariff_scheme_name_")
  }
  # *** For dropdowns ***
  scope :for_dropdown_by_office, -> office {
    joins("INNER JOIN street_directories on subscribers.street_directory_id=street_directories.id")
    .joins("INNER JOIN street_types on street_directories.street_type_id=street_types.id")
    .select("subscribers.id,
             CONCAT(SUBSTR(subscribers.subscriber_code,1,4), '-', SUBSTR(subscribers.subscriber_code,5,7), ' ',
                    CASE WHEN ISNULL(subscribers.company) THEN CONCAT(subscribers.last_name, ', ', subscribers.first_name) ELSE subscribers.company END, ' - ',
                    CONCAT(street_types.street_type_code, ' ', street_directories.street_name, ' ', subscribers.street_number, (CASE WHEN NOT ISNULL(subscribers.building) AND subscribers.building<>'' THEN CONCAT(', ', subscribers.building) ELSE '' END), (CASE WHEN NOT ISNULL(subscribers.floor) AND subscribers.floor<>'' THEN CONCAT(', ', subscribers.floor) ELSE '' END), (CASE WHEN NOT ISNULL(subscribers.floor_office) AND subscribers.floor_office<>'' THEN CONCAT(' ', subscribers.floor_office) ELSE '' END))) to_label_")
    .by_code
    .where(office_id: office)
  }
  scope :for_dropdown, -> {
    joins("INNER JOIN street_directories on subscribers.street_directory_id=street_directories.id")
    .joins("INNER JOIN street_types on street_directories.street_type_id=street_types.id")
    .select("subscribers.id,
             CONCAT(SUBSTR(subscribers.subscriber_code,1,4), '-', SUBSTR(subscribers.subscriber_code,5,7), ' ',
                    CASE WHEN ISNULL(subscribers.company) THEN CONCAT(subscribers.last_name, ', ', subscribers.first_name) ELSE subscribers.company END, ' - ',
                    CONCAT(street_types.street_type_code, ' ', street_directories.street_name, ' ', subscribers.street_number, (CASE WHEN NOT ISNULL(subscribers.building) AND subscribers.building<>'' THEN CONCAT(', ', subscribers.building) ELSE '' END), (CASE WHEN NOT ISNULL(subscribers.floor) AND subscribers.floor<>'' THEN CONCAT(', ', subscribers.floor) ELSE '' END), (CASE WHEN NOT ISNULL(subscribers.floor_office) AND subscribers.floor_office<>'' THEN CONCAT(' ', subscribers.floor_office) ELSE '' END))) to_label_")
    .by_code
  }
  scope :with_these_ids, -> ids {
    includes([street_directory: :street_type],[tariffs: :tariff_type],[water_supply_contract: :contracting_request], :meter, :office, :use, :tariffs)
    .where(id: ids)
  }

  # Callbacks
  before_validation :fields_to_uppercase
  before_destroy :check_for_dependent_records
  before_save :inhabitants_expire_change_annotation

  # Methods
  def fields_to_uppercase
    if !self.fiscal_id.blank?
      self[:fiscal_id].upcase!
    end
    if !self.subscriber_code.blank?
      self[:subscriber_code].upcase!
    end
  end

  def to_label
    if !self.last_name.blank? && !self.first_name.blank?
      "#{full_name_and_code}"
    else
      "#{full_code} #{company}"
    end
  end

  def full_name
    full_name = ""
    if !company.blank?
      full_name = company
    else
      if !self.last_name.blank?
        full_name += self.last_name
      end
      if !self.first_name.blank?
        full_name += ", " + self.first_name
      end
      full_name[0,40]
    end
  end
  def full_name_full
    full_name = ""
    if !company.blank?
      full_name = company
    else
      if !self.last_name.blank?
        full_name += self.last_name
      end
      if !self.first_name.blank?
        full_name += ", " + self.first_name
      end
    end
    full_name
  end

  def full_name_and_code
    full_name = ""
    if !self.last_name.blank?
      full_name += self.last_name
    end
    if !self.first_name.blank?
      full_name += ", " + self.first_name
    end
    full_name = full_code + " " + full_name[0,40]
  end

  def full_name_or_company
    full_name_or_company = ""
    if !self.last_name.blank? || !self.first_name.blank?
      full_name_or_company = full_name
    else
      full_name_or_company = company[0,40] if !company.blank?
    end
    full_name_or_company
  end

  def full_name_or_company_and_code
    full_code + " " + full_name_or_company
  end

  def code_full_name_or_company_address
    full_code + " " + full_name_or_company + " - " + address_1
  end

  def code_full_name_or_company_address_fiscal
    subscriber_code + " " + full_name_or_company + " " + address_1 + " " + fiscal_id
  end

  def code_full_name_or_company_address_fiscal_2
    subscriber_code + " " + full_name_or_company + " " + subscriber_supply_address.supply_address + " " + fiscal_id
  end

  def code_full_name_or_company_fiscal
    subscriber_code + " " + full_name_or_company + " " + fiscal_id
  end

  def full_code
    # Subscriber code (Office id & sequential number) => OOOO-NNNNNNN
    subscriber_code.blank? ? "" : subscriber_code[0..3] + '-' + subscriber_code[4..10]
  end

  # Subscribed (suscripto, de alta) & active
  def activated?
    subscribed? && active
  end
  # Subscribed (suscripto, de alta) & inactive
  def deactivated?
    subscribed? && !active
  end

  # Subscribed (suscripto, de alta)
  def subscribed?
    (ending_at.nil? || ending_at >= Date.today)
  end
  # Unsubscribed (anulado, de baja)
  def unsubscribed?
    !ending_at.nil?
  end

  #
  # Tariffs
  #
  def current_tariffs(_reading_date=nil)
    unless tariffs.blank?
      if _reading_date.nil?
        tariffs.where("subscriber_tariffs.ending_at IS NULL")
        .sort{|a,b| a.percentage_applicable_formula && b.percentage_applicable_formula ? a.percentage_applicable_formula <=> b.percentage_applicable_formula : a.percentage_applicable_formula ? 1 : -1 }
        .group_by{|t| t.try(:billable_item).try(:biller_id)}
      else
        tariffs
        .where('(? BETWEEN subscriber_tariffs.starting_at AND subscriber_tariffs.ending_at) OR (? >= subscriber_tariffs.starting_at AND subscriber_tariffs.ending_at IS NULL)', _reading_date, _reading_date)
        .sort{|a,b| a.percentage_applicable_formula && b.percentage_applicable_formula ? a.percentage_applicable_formula <=> b.percentage_applicable_formula : a.percentage_applicable_formula ? 1 : -1 }
        .group_by{|t| t.try(:billable_item).try(:biller_id)}
      end
    else
      []
    end
  end

  def tariffs_supply
    unless tariffs.blank?
      tariffs
      .where("subscriber_tariffs.ending_at IS NULL")
      .sort{|a,b| a.percentage_applicable_formula && b.percentage_applicable_formula ? a.percentage_applicable_formula <=> b.percentage_applicable_formula : a.percentage_applicable_formula ? 1 : -1 }
      .group_by{|t| t.try(:billable_item).try(:biller_id)}
    else
      []
    end
  end

  #
  # Calculated fields
  #
  def total_debt_unpaid
    invoice_debts.unpaid.sum(:debt)
  end

  def total_existing_debt
    invoice_debts.existing_debt.sum(:debt)
  end

  def total_debt
    invoices.sum(&:debt)
  end

  def current_debt
    Subscriber.current_debt_calc(self.id)
  end

  def totals_date(from,to,i=nil)
    if i.nil?
      i = self.id
    end
    ActiveRecord::Base.connection.exec_query(
      "SELECT SUM(total) as total_total FROM
        (
        SELECT SUM(receivables) as total, 0 as collected
        FROM invoices
        INNER join bills ON invoices.bill_id = bills.id
        WHERE bills.subscriber_id = #{i} AND (invoices.invoice_date >= '#{from.to_date}' AND invoices.invoice_date <= '#{to.to_date}')
        UNION
        SELECT 0 as total, SUM(amount) as collected
        FROM client_payments
        INNER join invoices ON client_payments.invoice_id = invoices.id
        WHERE client_payments.subscriber_id = #{i} AND (invoices.invoice_date >= '#{from.to_date}' AND invoices.invoice_date <= '#{to.to_date}') AND NOT ISNULL(client_payments.confirmation_date)
        ) a"
    ).first["total_total"]
  end

  def collected_date(from,to,i=nil)
    if i.nil?
      i = self.id
    end
    ActiveRecord::Base.connection.exec_query(
      "SELECT SUM(collected) as collected_total FROM
        (
        SELECT SUM(receivables) as total, 0 as collected
        FROM invoices
        INNER join bills ON invoices.bill_id = bills.id
        WHERE bills.subscriber_id = #{i} AND (invoices.invoice_date >= '#{from.to_date}' AND invoices.invoice_date <= '#{to.to_date}')
        UNION
        SELECT 0 as total, SUM(amount) as collected
        FROM client_payments
        INNER join invoices ON client_payments.invoice_id = invoices.id
        WHERE client_payments.subscriber_id = #{i} AND (invoices.invoice_date >= '#{from.to_date}' AND invoices.invoice_date <= '#{to.to_date}') AND NOT ISNULL(client_payments.confirmation_date)
        ) a"
    ).first["collected_total"]
  end

  def debt_date(from,to,i=nil)
    if i.nil?
      i = self.id
    end
    ActiveRecord::Base.connection.exec_query(
      "SELECT SUM(total)-SUM(collected) as debt FROM
        (
        SELECT SUM(receivables) as total, 0 as collected
        FROM invoices
        INNER join bills ON invoices.bill_id = bills.id
        WHERE bills.subscriber_id = #{i} AND (invoices.invoice_date >= '#{from.to_date}' AND invoices.invoice_date <= '#{to.to_date}')
        UNION
        SELECT 0 as total, SUM(amount) as collected
        FROM client_payments
        INNER join invoices ON client_payments.invoice_id = invoices.id
        WHERE client_payments.subscriber_id = #{i} AND (invoices.invoice_date >= '#{from.to_date}' AND invoices.invoice_date <= '#{to.to_date}') AND NOT ISNULL(client_payments.confirmation_date)
        ) a"
    ).first["debt"]
  end

  def totals_current_date(from,to,todebt,i=nil)
    if i.nil?
      i = self.id
    end
    ActiveRecord::Base.connection.exec_query(
      "SELECT SUM(total) as total_total FROM
        (
        SELECT SUM(receivables) as total, 0 as collected
        FROM invoices
        INNER join bills ON invoices.bill_id = bills.id
        WHERE bills.subscriber_id = #{i} AND (invoices.invoice_date >= '#{from.to_date}' AND invoices.invoice_date <= '#{to.to_date}')
        UNION
        SELECT 0 as total, SUM(amount) as collected
        FROM client_payments
        INNER join invoices ON client_payments.invoice_id = invoices.id
        WHERE client_payments.subscriber_id = #{i} AND client_payments.payment_date <= '#{todebt.to_date}' AND (invoices.invoice_date >= '#{from.to_date}' AND invoices.invoice_date <= '#{to.to_date}') AND NOT ISNULL(client_payments.confirmation_date)
        ) a"
    ).first["total_total"]
  end

  def collected_current_date(from,to,todebt,i=nil)
    if i.nil?
      i = self.id
    end
    ActiveRecord::Base.connection.exec_query(
      "SELECT SUM(collected) as collected_total FROM
        (
        SELECT SUM(receivables) as total, 0 as collected
        FROM invoices
        INNER join bills ON invoices.bill_id = bills.id
        WHERE bills.subscriber_id = #{i} AND (invoices.invoice_date >= '#{from.to_date}' AND invoices.invoice_date <= '#{to.to_date}')
        UNION
        SELECT 0 as total, SUM(amount) as collected
        FROM client_payments
        INNER join invoices ON client_payments.invoice_id = invoices.id
        WHERE client_payments.subscriber_id = #{i} AND client_payments.payment_date <= '#{todebt.to_date}' AND (invoices.invoice_date >= '#{from.to_date}' AND invoices.invoice_date <= '#{to.to_date}') AND NOT ISNULL(client_payments.confirmation_date)
        ) a"
    ).first["collected_total"]
  end

  def debt_current_date(from,to,todebt,i=nil)
    if i.nil?
      i = self.id
    end
    ActiveRecord::Base.connection.exec_query(
      "SELECT SUM(total)-SUM(collected) as debt FROM
        (
        SELECT SUM(receivables) as total, 0 as collected
        FROM invoices
        INNER join bills ON invoices.bill_id = bills.id
        WHERE bills.subscriber_id = #{i} AND (invoices.invoice_date >= '#{from.to_date}' AND invoices.invoice_date <= '#{to.to_date}')
        UNION
        SELECT 0 as total, SUM(amount) as collected
        FROM client_payments
        INNER join invoices ON client_payments.invoice_id = invoices.id
        WHERE client_payments.subscriber_id = #{i} AND client_payments.payment_date <= '#{todebt.to_date}' AND (invoices.invoice_date >= '#{from.to_date}' AND invoices.invoice_date <= '#{to.to_date}') AND NOT ISNULL(client_payments.confirmation_date)
        ) a"
    ).first["debt"]
  end

  # Historical estimation (based on all invoices)
  def total_consumption_estimated
    invoices.reject(&:marked_for_destruction?).sum(:consumption_estimated)
  end

  #
  # Consumption estimates
  #
  def current_estimation
    subscriber_estimation_balances.active.last rescue nil
  end
  def current_estimation_balance
    current_estimation.estimation_balance rescue 0
  end

  #
  # Postal & notifications
  #
  def full_name_postal
    postal_full_name = ""
    if !self.postal_last_name.blank?
      postal_full_name += self.postal_last_name
    end
    if !self.postal_first_name.blank?
      postal_full_name += ", " + self.postal_first_name
    end
    postal_full_name[0,40]
  end

  def right_postal_name
    if !self.postal_last_name.blank? && !self.postal_first_name.blank?
      "#{full_name_postal}"
    elsif !self.postal_company.blank?
      postal_company
    elsif !self.client.blank?
      client.try(:to_name)
    else
      ""
    end
  end

  def right_postal_street_name
    if !self.postal_street_name.blank?
      postal_street_name
    elsif !self.client.blank?
      client.try(:street_name)
    else
      ""
    end
  end

  def right_postal_street_number
    if !self.postal_street_number.blank?
      postal_street_number
    elsif !self.client.blank?
      client.try(:street_number)
    else
      ""
    end
  end

  def right_postal_building
    if !self.postal_building.blank?
      postal_building
    elsif !self.client.blank?
      client.try(:building)
    else
      ""
    end
  end

  def right_postal_floor
    if !self.postal_floor.blank?
      postal_floor
    elsif !self.client.blank?
      client.try(:floor)
    else
      ""
    end
  end

  def right_postal_floor_office
    if !self.postal_floor_office.blank?
      postal_floor_office
    elsif !self.client.blank?
      client.try(:floor_office)
    else
      ""
    end
  end

  def right_postal_town
    if !self.postal_town.blank?
      postal_town.try(:name)
    elsif !self.client.blank?
      client.try(:town).try(:name)
    else
      ""
    end
  end

  def right_postal_zipcode
    if !self.postal_zipcode.blank?
      postal_zipcode.try(:zipcode)
    elsif !self.client.blank?
      client.try(:zipcode).try(:zipcode)
    else
      ""
    end
  end

  def right_postal_province
    if !self.postal_province.blank?
      postal_province.try(:name)
    elsif !self.client.blank?
      client.try(:province).try(:name)
    else
      ""
    end
  end

  def right_postal_region
    if !self.postal_region.blank?
      postal_region.try(:name)
    elsif !self.client.blank?
      client.try(:region).try(:name)
    else
      ""
    end
  end

  def right_postal_country
    if !self.postal_country.blank?
      postal_country.try(:name)
    elsif !self.client.blank?
      client.try(:country).try(:name)
    else
      ""
    end
  end

  def right_phone
    if !self.phone.blank?
      phone
    elsif !self.client.blank?
      client.try(:phone)
    else
      ""
    end
  end

  def right_cellular
    if !self.cellular.blank?
      cellular
    elsif !self.client.blank?
      client.try(:cellular)
    else
      ""
    end
  end

  def right_fax
    if !self.fax.blank?
      fax
    elsif !self.client.blank?
      client.try(:fax)
    else
      ""
    end
  end

  def right_email
    if !self.email.blank?
      email
    elsif !self.client.blank?
      client.try(:email)
    else
      ""
    end
  end

  #
  # For banking
  #
  def diput
    subscriber_code.blank?  || subscriber_code == "$ERR" ? "00000000" : subscriber_code[2..3] + subscriber_code[5..10]
  end

  def for_sepa_mandate_id
    self.id.blank? ? '00000000' : self.id.to_s.rjust(8,'0')
  end

  def active_bank_accounts?
    (client_bank_accounts_count > 0) && (!client_bank_accounts.where(ending_at: nil).blank?)
  end
  def active_bank_account
    client_bank_accounts.where(ending_at: nil).order(:starting_at).last
  end

  #
  # Client
  #
  def client_first_name
    self.client.first_name
  end

  def client_last_name
    self.cllient.last_name
  end

  def client_company
    self.client.company
  end

  #
  # Supply address
  #
  def supply_address
    subscriber_supply_address.supply_address unless (subscriber_supply_address.blank? || subscriber_supply_address.supply_address.blank?)
  end

  def address_1
    _ret = ""
    if !street_directory.blank?
      _ret += street_directory.street_type.street_type_code + ". "
      _ret += street_directory.street_name + " "
    end
    if !street_number.blank?
      _ret += street_number
    end
    if !building.blank?
      _ret += ", " + building.titleize
    end
    if !floor.blank?
      _ret += ", " + floor_human
    end
    if !floor_office.blank?
      _ret += " " + floor_office
    end
    _ret
  end

  def address_2
    _ret = ""
    if !zipcode.blank?
      _ret += zipcode.zipcode + " "
    end
    if !street_directory.blank?
      _ret += street_directory.town.name + ", "
      _ret += street_directory.town.province.name + " "
      if !street_directory.town.province.region.country.blank?
        _ret += "(" + street_directory.town.province.region.country.name + ")"
      end
    end
    _ret
  end

  def floor_human
    _ret = floor
    _floor_is_numeric = true if Float(floor) rescue false
    if _floor_is_numeric
      _ret = floor.strip + "\xBA".force_encoding('ISO-8859-1').encode('UTF-8')
    end
    _ret
  end

  def use_name
    use.blank? ? "" : use.right_name
  end

  def right_equiv_dwelling
    equiv_dwelling.nil? || equiv_dwelling == 0 ? 1 : equiv_dwelling
  end

  def right_inhabitants
    inhabitants.nil? || inhabitants == 0 ? 1 : inhabitants
  end

  def right_endowments
    endowments.nil? || endowments == 0 ? 1 : endowments
  end

  def right_inhabitants_and_endowments
    _i = inhabitants.nil? ? 0 : inhabitants
    _e = endowments.nil? ? 0 : endowments
    _ie = _i + _e
    _ie == 0 ? 1 : _ie
  end

  #
  # Meter & users
  #
  def meter_code
    meter.blank? ? "" : meter.meter_code
  end

  def meter_caliber
    meter.blank? ? "" : meter.caliber_id
  end

  def is_master_meter?
    meter.is_master? rescue false
  end
  def is_child_meter?
    meter.is_child? rescue false
  end

  def meter_users
    meter.users + 1
  end

  def subscriber_id
    self.id
  end

  # For CSV
  def raw_number(_number, _d)
    formatted_number_without_delimiter(_number, _d)
  end

  def sanitize(s)
    !s.blank? ? sanitize_string(s.strip, true, true, true, false) : ''
  end

  #
  # Class (self) user defined methods
  #
  def self.find_by_organization(_organization)
    joins(:office => :company).where("companies.organization_id = ?", _organization).by_code
    #includes(:office => :company).where("companies.organization_id = ?)", _organization).by_code
  end

  def self.find_by_company(_company, _organization)
    joins(:office => :company).where("offices.company_id = ? OR (offices.company_id IS NULL AND companies.organization_id = ?)", _company, _organization).by_code
    #includes(:office => :company).where("offices.company_id = ? OR (offices.company_id IS NULL AND companies.organization_id = ?)", _company, _organization).by_code
  end

  def self.find_by_office(_office, _organization)
    joins(:office => :company).where("office_id = ? OR (office_id IS NULL AND companies.organization_id = ?)", _office, _organization).by_code
    #includes(:office => :company).where("office_id = ? OR (office_id IS NULL AND companies.organization_id = ?)", _company, _organization).by_code
  end

  def self.dropdown(office=nil)
    if office.present?
      self.for_dropdown_by_office(office)
    else
      self.for_dropdown
    end
  end

  def self.current_debt_calc(i=nil)
    if i.nil?
      i = self.id
    end
    ActiveRecord::Base.connection.exec_query(
      "SELECT SUM(total)-SUM(collected) as debt FROM
        (
        SELECT SUM(receivables) as total, 0 as collected
        FROM invoices
        INNER join bills ON invoices.bill_id = bills.id
        WHERE bills.subscriber_id = #{i}
        UNION
        SELECT 0 as total, SUM(amount) as collected
        FROM client_payments
        WHERE client_payments.subscriber_id = #{i} AND NOT ISNULL(client_payments.confirmation_date)
        ) a"
    ).first["debt"]
  end

  def self.to_csv(array)
    attributes = [array[0].sanitize("Id"),
                  array[0].sanitize(I18n.t('activerecord.attributes.subscriber.subscriber_code')),
                  array[0].sanitize(I18n.t('activerecord.attributes.subscriber.fiscal_id_c')),
                  array[0].sanitize(I18n.t('activerecord.attributes.subscriber.full_name')),
                  array[0].sanitize(I18n.t('activerecord.attributes.subscriber.address_1')),
                  array[0].sanitize(I18n.t('activerecord.attributes.subscriber.office')),
                  array[0].sanitize(I18n.t('activerecord.attributes.subscriber.use_id')),
                  array[0].sanitize(I18n.t('activerecord.attributes.subscriber.ending_at')),
                  array[0].sanitize(I18n.t('activerecord.attributes.subscriber.starting_at')),
                  array[0].sanitize(I18n.t('activerecord.attributes.subscriber.meter_id')),
                  array[0].sanitize(I18n.t('activerecord.attributes.subscriber.reading_route_id')),
                  array[0].sanitize(I18n.t('activerecord.attributes.subscriber.data_contract')),
                  array[0].sanitize(I18n.t('activerecord.attributes.subscriber.tariff_type_id')),
                  array[0].sanitize(I18n.t('activerecord.attributes.subscriber.debt'))]

    col_sep = I18n.locale == :es ? ";" : ","
    CSV.generate(headers: true, col_sep: col_sep, row_sep: "\r\n") do |csv|
      csv << attributes
      # array.each do |subscriber|
      Subscriber.uncached do
        array.find_each do |subscriber|
          if !subscriber.tariffs.blank?
            _tariff_type = []
            subscriber.subscriber_tariffs.each do |tt|
              if !_tariff_type.include? tt.tariff.tariff_type.name
                _tariff_type = _tariff_type << tt.tariff.tariff_type.name
              end
            end
            tariff_type = _tariff_type.join(",")
          else
            tariff_type = ""
          end
          starting_at = subscriber.formatted_date(subscriber.starting_at) unless subscriber.starting_at.blank?
          ending_at = subscriber.formatted_date(subscriber.ending_at) unless subscriber.ending_at.blank?
          csv << [ subscriber.id,
                   subscriber.subscriber_code,
                   subscriber.fiscal_id,
                   subscriber.full_name,
                   subscriber.address_1,
                   subscriber.try(:office).try(:name),
                   subscriber.try(:use).try(:name),
                   starting_at,
                   ending_at,
                   subscriber.try(:meter).try(:meter_code),
                   subscriber.try(:reading_route).try(:to_label),
                   subscriber.try(:water_supply_contract).try(:contracting_request).try(:full_no),
                   tariff_type,
                   subscriber.current_debt]
        end
      end
    end
  end

  #
  # Records navigator
  #
  # Using self.class
  def to_first
    Subscriber.order("subscriber_code").first
  end
  def to_prev
    Subscriber.where("subscriber_code < ?", subscriber_code).order("subscriber_code").last
  end
  def to_next
    Subscriber.where("subscriber_code > ?", subscriber_code).order("subscriber_code").first
  end
  def to_last
    Subscriber.order("subscriber_code").last
  end

  # Using received dataset
  def goto_first(dataset=self.class)
    dataset.by_code_desc.first
  end
  def goto_prev(dataset=self.class)
    dataset.where("subscriber_code > ?", subscriber_code).by_code_desc.last
  end
  def goto_next(dataset=self.class)
    dataset.where("subscriber_code < ?", subscriber_code).by_code_desc.first
  end
  def goto_last(dataset=self.class)
    dataset.by_code_desc.last
  end

  # Using received sorted by code (descendant) array of Ids
  def goto_first_a(ids=[])
    Subscriber.find(ids.first) rescue Subscriber.find(self.id)
  end
  def goto_prev_a(ids=[])
    i = ids.index(self.id)
    if i == 0 || i.nil?
      # Index is the first one or doesn't exist, mustn't go backward
      Subscriber.find(self.id)
    else
      # GoTo previous element
      Subscriber.find(ids[i-1])
    end
  end
  def goto_next_a(ids=[])
    i = ids.index(self.id)
    if i == ids.length-1 || i.nil?
      # Index is the last one or doesn't exist, mustn't go backward
      Subscriber.find(self.id)
    else
      # GoTo next element
      Subscriber.find(ids[i+1])
    end
  end
  def goto_last_a(ids=[])
    Subscriber.find(ids.last) rescue Subscriber.find(self.id)
  end

  #
  # Sunspot searchable block
  #
  searchable do
    text :subscriber_code, :to_label, :fiscal_id, :phone, :full_name
    # text :street_name do
    #   street_directory.street_name unless street_directory.blank?
    # end
    # text :meter_code_txt do
    #   meter.meter_code unless meter.blank?
    # end
    string :supply_address, :multiple => true do
      subscriber_supply_address.supply_address unless (subscriber_supply_address.blank? || subscriber_supply_address.supply_address.blank?)
    end
    string :meter_code, :multiple => true do
      meter_code
    end
    string :subscriber_code, :multiple => true   # Multiple search values accepted in one search (inverse_no_search)
    string :full_name
    integer :service_point_id
    integer :meter_id
    integer :reading_route_id
    integer :billing_frequency_id
    integer :use_id
    integer :office_id, :multiple => true
    time :starting_at
    time :ending_at
    integer :subscriber_id do
      subscriber_id
    end
    integer :tariff_type_id do
      tariffs.first.tariff_type_id unless (tariffs.blank? || tariffs.first.tariff_type_id.blank?)
    end
    integer :caliber_id do
      meter_caliber
    end
    boolean :active
    boolean :activated do
      activated?
    end
    boolean :deactivated do
      deactivated?
    end
    boolean :subscribed do
      subscribed?
    end
    boolean :unsubscribed do
      unsubscribed?
    end
    string :sort_no do
      subscriber_code
    end
  end

  private

  # Before destroy
  def check_for_dependent_records
    # Check for work orders
    if work_orders.count > 0
      errors.add(:base, I18n.t('activerecord.models.subscriber.check_for_work_orders'))
      return false
    end
    # Check for meter details
    if meter_details.count > 0
      errors.add(:base, I18n.t('activerecord.models.subscriber.check_for_meter_details'))
      return false
    end
    # Check for contracting requests
    if !water_supply_contract.nil? and !water_supply_contract.try(:contracting_request).nil?
      errors.add(:base, I18n.t('activerecord.models.subscriber.check_for_contracting_request'))
      return false
    end
    # Check for water supply contracts
    if !water_supply_contract.nil? and water_supply_contract.count > 0
      errors.add(:base, I18n.t('activerecord.models.subscriber.check_for_water_supply_contract'))
      return false
    end
    # Check for readings
    if readings.count > 0
      errors.add(:base, I18n.t('activerecord.models.subscriber.check_for_readings'))
      return false
    end
    # Check for prereadings
    if pre_readings.count > 0
      errors.add(:base, I18n.t('activerecord.models.subscriber.check_for_pre_readings'))
      return false
    end
    # Check for bills
    if bills.count > 0
      errors.add(:base, I18n.t('activerecord.models.subscriber.check_for_bills'))
      return false
    end
    # Check for prebills
    if pre_bills.count > 0
      errors.add(:base, I18n.t('activerecord.models.subscriber.check_for_pre_bills'))
      return false
    end
  end

  def inhabitants_expire_change_annotation
    iea_has_changed = inhabitants_ending_at_changed? rescue false
    iea_prev = inhabitants_ending_at_was rescue inhabitants_ending_at
    if iea_has_changed && iea_prev != inhabitants_ending_at
      annotation_created_by = (!updated_by.blank? ? updated_by : created_by) rescue created_by
      if iea_prev.blank?
        annotation = formatted_date(inhabitants_ending_at)
      else
        annotation = formatted_date(iea_prev) + " => " + formatted_date(inhabitants_ending_at)
      end
      SubscriberAnnotation.create(
                          subscriber_id: self.id,
                          annotation: annotation,
                          created_by: annotation_created_by,
                          subscriber_annotation_class_id: 1)

    end
  end
end
