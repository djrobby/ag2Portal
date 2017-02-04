class Subscriber < ActiveRecord::Base
  belongs_to :client
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
  attr_accessible :company, :first_name, :fiscal_id, :last_name, :subscriber_code,
                  :starting_at, :ending_at, :created_by, :updated_by,
                  :client_id, :office_id, :center_id, :street_directory_id, :street_number,
                  :building, :floor, :floor_office, :zipcode_id, :phone, :fax, :cellular, :email,
                  :service_point_id, :active, :tariff_scheme_id, :billing_frequency_id, :meter_id,
                  :reading_route_id, :reading_sequence, :reading_variant, :contracting_request_id, :use_id,
                  :remarks, :cadastral_reference, :gis_id, :endowments, :inhabitants, :km, :gis_id_wc,
                  :readings_attributes, :meter_details_attributes

  attr_accessor :reading_index_add, :reading_date_add

  has_many :work_orders
  has_many :meter_details
  has_one :contracting_request
  has_one :water_supply_contract
  has_many :readings
  has_many :pre_readings
  has_many :pre_bills
  has_many :bills
  has_many :client_payments
  has_many :subscriber_tariffs
  has_many :tariffs, through: :subscriber_tariffs
  has_many :cancelled_invoices
  has_many :active_invoices
  has_many :active_supply_invoices
  has_many :invoice_debts
  has_many :invoice_bills
  has_many :invoice_credits
  has_many :invoice_rebills

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
  scope :by_code, -> { order(:subscriber_code) }
  #
  scope :belongs_to_office, -> office { where("office_id = ?", office).by_code }
  scope :availables, -> { where(ending_at: nil) }

  before_validation :fields_to_uppercase
  before_destroy :check_for_dependent_records

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

  def total_debt_unpaid
    bills.map(&:invoices).flatten.map{|i| i.debt if !i.payday_limit or i.payday_limit < Date.today}.compact.sum{|i| i}
  end

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

  def full_code
    # Subscriber code (Office id & sequential number) => OOOO-NNNNNNN
    subscriber_code.blank? ? "" : subscriber_code[0..3] + '-' + subscriber_code[4..10]
  end

  def client_first_name
    self.client.first_name
  end

  def client_last_name
    self.cllient.last_name
  end

  def client_company
    self.client.company
  end

  def address_1
    _ret = ""
    if !street_directory.blank?
      _ret += street_directory.street_type.street_type_code.titleize + ". "
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

  def total_debt_unpaid
    bills.map(&:invoices).flatten.map{|i| i.debt if !i.payday_limit or i.payday_limit < Date.today}.compact.sum{|i| i}
  end

  def meter_code
    meter.blank? ? "" : meter.meter_code
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

  #
  # Records navigator
  #
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

  searchable do
    text :subscriber_code, :to_label, :fiscal_id, :phone, :full_name
    text :street_name do
      street_directory.street_name unless street_directory.blank?
    end
    text :meter_code do
      meter.meter_code unless meter.blank?
    end
    string :subscriber_code, :multiple => true   # Multiple search values accepted in one search (inverse_no_search)
    string :full_name
    integer :service_point_id
    integer :meter_id
    integer :billing_frequency_id
    integer :office_id, :multiple => true
    time :starting_at
    time :ending_at
    integer :tariff_type_id do
      tariff_scheme.tariff_type_id
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
end
