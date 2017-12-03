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
                  :postal_province_id, :postal_region_id, :postal_country_id, :non_billable

  attr_accessor :reading_index_add, :reading_date_add

  has_many :work_orders
  has_many :meter_details
  has_one :contracting_request
  has_one :water_supply_contract
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
  scope :actives, -> { where(active: true).by_code }
  scope :active_by_office, -> office { where(active: true, office_id: office).by_code }
  scope :availables, -> { where("ending_at IS NULL OR ending_at >= ?", Date.today)}
  scope :unavailables, -> { where("NOT ending_at IS NULL OR active = false") }
  scope :activated, -> { where("(ending_at IS NULL OR ending_at >= ?) AND active = true", Date.today)}
  scope :activated_by_office, -> office { where("((ending_at IS NULL OR ending_at >= ?) AND active = true) AND office_id = ?", Date.today, office).by_code }

  # Callbacks
  before_validation :fields_to_uppercase
  before_destroy :check_for_dependent_records

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

  def total_debt_unpaid
    invoice_debts.unpaid.sum(:debt)
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

  def meter_code
    meter.blank? ? "" : meter.meter_code
  end

  def meter_caliber
    meter.blank? ? "" : meter.caliber_id
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
    integer :billing_frequency_id
    integer :use_id
    integer :office_id, :multiple => true
    time :starting_at
    time :ending_at
    integer :tariff_type_id do
      tariffs.first.tariff_type_id unless (tariffs.blank? || tariffs.first.tariff_type_id.blank?)
    end
    integer :caliber_id do
      meter_caliber
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
