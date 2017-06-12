class Supplier < ActiveRecord::Base
  has_and_belongs_to_many :activities, :join_table => :suppliers_activities
  belongs_to :country
  belongs_to :region
  belongs_to :province
  belongs_to :town
  belongs_to :zipcode
  belongs_to :street_type
  belongs_to :payment_method
  belongs_to :entity
  belongs_to :organization
  belongs_to :ledger_account
  attr_accessible :fiscal_id, :name, :supplier_code,
                  :street_type_id, :street_name, :street_number, :building, :floor, :floor_office,
                  :zipcode_id, :town_id, :province_id, :phone, :fax, :cellular, :email,
                  :region_id, :country_id, :payment_method_id, :ledger_account_id, :discount_rate,
                  :active, :max_orders_count, :max_orders_sum, :contract_number, :remarks,
                  :created_by, :updated_by, :entity_id, :organization_id,
                  :is_contact, :shared_contact_id, :order_authorization, :free_shipping_sum
  attr_accessible :activity_ids
  attr_accessible :supplier_bank_accounts_attributes

  has_many :supplier_contacts, dependent: :destroy
  has_many :supplier_bank_accounts, dependent: :destroy
  has_many :purchase_prices, dependent: :destroy
  has_many :products, :through => :purchase_prices
  has_many :receipt_notes
  has_many :purchase_orders
  has_many :offer_request_suppliers
  has_many :offer_requests, through: :offer_request_suppliers
  has_many :offers
  has_many :supplier_invoices
  has_many :supplier_payments
  has_many :supplier_invoice_debts
  has_many :product_company_prices
  has_many :supplier_ledger_accounts, dependent: :destroy

  # Nested attributes
  accepts_nested_attributes_for :supplier_bank_accounts,
                                :reject_if => :all_blank,
                                :allow_destroy => true
  accepts_nested_attributes_for :supplier_ledger_accounts,
                                :reject_if => :all_blank,
                                :allow_destroy => true

  has_paper_trail

  validates_associated :supplier_bank_accounts
  validates_associated :supplier_ledger_accounts

  validates :name,            :presence => true
  validates :supplier_code,   :presence => true,
                              :length => { :is => 14 },
                              :format => { with: /\A\d+\Z/, message: :code_invalid },
                              :uniqueness => { :scope => :organization_id }
  validates :fiscal_id,       :presence => true,
                              :length => { :minimum => 8 },
                              :uniqueness => { :scope => :organization_id }
  validates :street_type,     :presence => true
  validates :zipcode,         :presence => true
  validates :town,            :presence => true
  validates :province,        :presence => true
  validates :region,          :presence => true
  validates :country,         :presence => true
  validates :payment_method,  :presence => true
  validates :entity,          :presence => true
  validates :organization,    :presence => true
  validates :activity_ids,    :presence => true

  # Scopes
  scope :by_code, -> { order(:supplier_code) }
  #
  scope :belongs_to_organization, -> o { where("organization_id = ?", o).by_code }
  scope :actives, -> { where(active: true).by_code }

  # Callbacks
  before_validation :fields_to_uppercase
  before_destroy :check_for_dependent_records
  after_create :should_create_shared_contact, if: :is_contact?
  after_update :should_update_shared_contact, if: :is_contact?

  def fields_to_uppercase
    if !self.fiscal_id.blank?
      self[:fiscal_id].upcase!
    end
    if !self.supplier_code.blank?
      self[:supplier_code].upcase!
    end
  end

  def to_label
    "#{full_name}"
  end

  def full_name
    full_name = full_code
    if !self.name.blank?
      full_name += " " + self.name[0,40]
    end
    full_name
  end

  def partial_name
    full_name = full_code
    if !self.name.blank?
      full_name += " " + self.name[0,20]
    end
    full_name
  end

  def partial_name30
    full_name = full_code
    if !self.name.blank?
      full_name += " " + self.name[0,30]
    end
    full_name
  end

  def full_code
    # Supplier code (Organization id & Main activity & sequential number) => OOOO-AAAA-NNNNNN
    supplier_code.blank? || supplier_code == "$ERR" ? "" : supplier_code[0..3] + '-' + supplier_code[4..7] + '-' + supplier_code[8..13]
  end

  def full_name_and_email
    full_name = full_code
    if !self.name.blank?
      full_name += " " + self.name[0,40]
    end
    if !self.email.blank?
      full_name += " (" + self.email + ")"
    end
    full_name
  end

  def address_1
    _ret = ""
    if !street_type.blank?
      _ret += street_type.street_type_code.titleize + ". "
    end
    if !street_name.blank?
      _ret += street_name + " "
    end
    if !street_number.blank?
      _ret += street_number + ", "
    end
    if !building.blank?
      _ret += building.titleize + ", "
    end
    if !floor.blank?
      _ret += floor_human + " "
    end
    if !floor_office.blank?
      _ret += floor_office
    end
    _ret
  end

  def address_2
    _ret = ""
    if !zipcode.blank?
      _ret += zipcode.zipcode + " "
    end
    if !town.blank?
      _ret += town.name + ", "
    end
    if !province.blank?
      _ret += province.name + " "
      if !province.region.country.blank?
        _ret += "(" + province.region.country.name + ")"
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

  #
  # Calculated fields
  #
  def active_yes_no
    active ? I18n.t(:yes_on) : I18n.t(:no_off)
  end

  #
  # Class (self) user defined methods
  #
  def self.to_csv(array)
    column_names = [I18n.t('activerecord.csv_sage200.supplier.c001'),
                    I18n.t('activerecord.csv_sage200.supplier.c002'),
                    I18n.t('activerecord.csv_sage200.supplier.c003'),
                    I18n.t('activerecord.csv_sage200.supplier.c004'),
                    I18n.t('activerecord.csv_sage200.supplier.c005'),
                    I18n.t('activerecord.csv_sage200.supplier.c006'),
                    I18n.t('activerecord.csv_sage200.supplier.c007'),
                    I18n.t('activerecord.csv_sage200.supplier.c008'),
                    I18n.t('activerecord.csv_sage200.supplier.c009'),
                    I18n.t('activerecord.csv_sage200.supplier.c010'),
                    I18n.t('activerecord.csv_sage200.supplier.c011'),
                    I18n.t('activerecord.csv_sage200.supplier.c012'),
                    I18n.t('activerecord.csv_sage200.supplier.c013'),
                    I18n.t('activerecord.csv_sage200.supplier.c014'),
                    I18n.t('activerecord.csv_sage200.supplier.c015'),
                    I18n.t('activerecord.csv_sage200.supplier.c016'),
                    I18n.t('activerecord.csv_sage200.supplier.c017'),
                    I18n.t('activerecord.csv_sage200.supplier.c018'),
                    I18n.t('activerecord.csv_sage200.supplier.c019'),
                    I18n.t('activerecord.csv_sage200.supplier.c020'),
                    I18n.t('activerecord.csv_sage200.supplier.c021'),
                    I18n.t('activerecord.csv_sage200.supplier.c022'),
                    I18n.t('activerecord.csv_sage200.supplier.c023'),
                    I18n.t('activerecord.csv_sage200.supplier.c024'),
                    I18n.t('activerecord.csv_sage200.supplier.c025'),
                    I18n.t('activerecord.csv_sage200.supplier.c026'),
                    I18n.t('activerecord.csv_sage200.supplier.c027'),
                    I18n.t('activerecord.csv_sage200.supplier.c028'),
                    I18n.t('activerecord.csv_sage200.supplier.c029'),
                    I18n.t('activerecord.csv_sage200.supplier.c030'),
                    I18n.t('activerecord.csv_sage200.supplier.c031'),
                    I18n.t('activerecord.csv_sage200.supplier.c032'),
                    I18n.t('activerecord.csv_sage200.supplier.c033'),
                    I18n.t('activerecord.csv_sage200.supplier.c034'),
                    I18n.t('activerecord.csv_sage200.supplier.c035'),
                    I18n.t('activerecord.csv_sage200.supplier.c036'),
                    I18n.t('activerecord.csv_sage200.supplier.c037'),
                    I18n.t('activerecord.csv_sage200.supplier.c038'),
                    I18n.t('activerecord.csv_sage200.supplier.c039'),
                    I18n.t('activerecord.csv_sage200.supplier.c040'),
                    I18n.t('activerecord.csv_sage200.supplier.c041'),
                    I18n.t('activerecord.csv_sage200.supplier.c042'),
                    I18n.t('activerecord.csv_sage200.supplier.c043'),
                    I18n.t('activerecord.csv_sage200.supplier.c044'),
                    I18n.t('activerecord.csv_sage200.supplier.c045'),
                    I18n.t('activerecord.csv_sage200.supplier.c046'),
                    I18n.t('activerecord.csv_sage200.supplier.c047'),
                    I18n.t('activerecord.csv_sage200.supplier.c048'),
                    I18n.t('activerecord.csv_sage200.supplier.c049'),
                    I18n.t('activerecord.csv_sage200.supplier.c050'),
                    I18n.t('activerecord.csv_sage200.supplier.c051'),
                    I18n.t('activerecord.csv_sage200.supplier.c052'),
                    I18n.t('activerecord.csv_sage200.supplier.c053'),
                    I18n.t('activerecord.csv_sage200.supplier.c054'),
                    I18n.t('activerecord.csv_sage200.supplier.c055'),
                    I18n.t('activerecord.csv_sage200.supplier.c056'),
                    I18n.t('activerecord.csv_sage200.supplier.c057'),
                    I18n.t('activerecord.csv_sage200.supplier.c058'),
                    I18n.t('activerecord.csv_sage200.supplier.c059'),
                    I18n.t('activerecord.csv_sage200.supplier.c060'),
                    I18n.t('activerecord.csv_sage200.supplier.c061'),
                    I18n.t('activerecord.csv_sage200.supplier.c062'),
                    I18n.t('activerecord.csv_sage200.supplier.c063'),
                    I18n.t('activerecord.csv_sage200.supplier.c064'),
                    I18n.t('activerecord.csv_sage200.supplier.c065'),
                    I18n.t('activerecord.csv_sage200.supplier.c066'),
                    I18n.t('activerecord.csv_sage200.supplier.c067'),
                    I18n.t('activerecord.csv_sage200.supplier.c068'),
                    I18n.t('activerecord.csv_sage200.supplier.c069'),
                    I18n.t('activerecord.csv_sage200.supplier.c070')]
    CSV.generate(headers: true) do |csv|
      csv << column_names
      array.each do |i|
        csv << ['1',  # 001
                'P',  # 002
                i.supplier_code,  # 003
                nil,  # 004
                nil,  # 005
                nil,  # 006
                nil,  # 007
                nil,  # 008
                nil,  # 009
                nil,  # 010
                nil,  # 011
                nil,  # 012
                nil,  # 013
                nil,  # 014
                nil,  # 015
                nil,  # 016
                nil,  # 017
                nil,  # 018
                nil,  # 019
                nil,  # 020
                nil,  # 021
                nil,  # 022
                nil,  # 023
                nil,  # 024
                nil,  # 025
                nil,  # 026
                nil,  # 027
                nil,  # 028
                nil,  # 029
                nil,  # 030
                nil,  # 031
                nil,  # 032
                nil,  # 033
                nil,  # 034
                nil,  # 035
                nil,  # 036
                nil,  # 037
                nil,  # 038
                nil,  # 039
                nil,  # 040
                nil,  # 041
                nil,  # 042
                nil,  # 043
                nil,  # 044
                nil,  # 045
                nil,  # 046
                nil,  # 047
                nil,  # 048
                nil,  # 049
                nil,  # 050
                nil,  # 051
                nil,  # 052
                nil,  # 053
                nil,  # 054
                nil,  # 055
                nil,  # 056
                nil,  # 057
                nil,  # 058
                nil,  # 059
                nil,  # 060
                nil,  # 061
                nil,  # 062
                nil,  # 063
                nil,  # 064
                nil,  # 065
                nil,  # 066
                nil,  # 067
                nil,  # 068
                nil,  # 069
                nil]  # 070
      end # array.each
    end # CSV.generate
  end

  #
  # Records navigator
  #
  def to_first
    Supplier.order("supplier_code").first
  end

  def to_prev
    Supplier.where("supplier_code < ?", supplier_code).order("supplier_code").last
  end

  def to_next
    Supplier.where("supplier_code > ?", supplier_code).order("supplier_code").first
  end

  def to_last
    Supplier.order("supplier_code").last
  end

  searchable do
    text :supplier_code, :name, :fiscal_id, :street_name, :phone, :cellular, :email
    string :supplier_code
    string :name
    integer :organization_id
  end

  private

  def check_for_dependent_records
    # Check for purchase orders
    if purchase_orders.count > 0
      errors.add(:base, I18n.t('activerecord.models.supplier.check_for_purchase_orders'))
      return false
    end
    # Check for receipt notes
    if receipt_notes.count > 0
      errors.add(:base, I18n.t('activerecord.models.supplier.check_for_receipt_notes'))
      return false
    end
    # Check for offer request suppliers
    if offer_request_suppliers.count > 0
      errors.add(:base, I18n.t('activerecord.models.supplier.check_for_offer_requests'))
      return false
    end
    # Check for offers
    if offers.count > 0
      errors.add(:base, I18n.t('activerecord.models.supplier.check_for_offers'))
      return false
    end
    # Check for supplier invoices
    if supplier_invoices.count > 0
      errors.add(:base, I18n.t('activerecord.models.supplier.check_for_supplier_invoices'))
      return false
    end
    # Check for supplier payments
    if supplier_payments.count > 0
      errors.add(:base, I18n.t('activerecord.models.supplier.check_for_supplier_payments'))
      return false
    end
  end

  #
  # Triggers to update linked models
  #
  # After create
  # Should create new Shared Contact (shared_contact_id not set)
  def should_create_shared_contact
    _entity = Entity.find(entity)
    # Maybe contact exists previously
    _contact = SharedContact.find_by_fiscal_id_organization_type(fiscal_id, organization_id, 2) rescue nil
    if _contact.nil?
      # Let's create a new contact
      _contact = create_shared_contact(_entity)
    else
      # Contact exists, updates it
      _contact = update_shared_contact(_contact, _entity)
    end
    # Update contact id
    self.update_column(:shared_contact_id, _contact.id) if !_contact.id.nil?
    true
  end

  # After update
  # Should update existing Shared Contact (shared_contact_id is set)
  def should_update_shared_contact
    _entity = Entity.find(entity)
    # Retrieve contact by its id
    _contact = SharedContact.find(shared_contact_id) rescue nil
    if _contact.nil?
      # Not found ??? Maybe is another contact... Let's check it out
      _contact = SharedContact.find_by_fiscal_id_organization_type(fiscal_id, organization_id, 2) rescue nil
      if _contact.nil?
        # No contact yet: Let's create a new one
        _contact = create_shared_contact(_entity)
      else
        # Contact exists but with a different id
        _contact = update_shared_contact(_contact, _entity)
      end
    else
      # Contact found, updates it
      _contact = update_shared_contact(_contact, _entity)
    end
    # Update contact id
    self.update_column(:shared_contact_id, _contact.id) if !_contact.id.nil?
    true
  end

  #
  # Helper methods for triggers
  #
  # Creates new Shared Contact
  def create_shared_contact(_entity)
    _contact = SharedContact.create(first_name: _entity.first_name, last_name: _entity.last_name, company: _entity.company,
                                    fiscal_id: fiscal_id, street_type_id: street_type_id, street_name: street_name,
                                    street_number: street_number, building: building, floor: floor,
                                    floor_office: floor_office, zipcode_id: zipcode_id, town_id: town_id,
                                    province_id: province_id, country_id: country_id, phone: phone,
                                    extension: _entity.extension, fax: fax, cellular: cellular,
                                    email: email, shared_contact_type_id: 2, region_id: region_id,
                                    organization_id: organization_id, created_by: created_by, updated_by: updated_by)
    return _contact
  end

  # Updates existing Shared Contact
  def update_shared_contact(_contact, _entity)
    _contact.attributes = { first_name: _entity.first_name, last_name: _entity.last_name, company: _entity.company,
                            fiscal_id: fiscal_id, street_type_id: street_type_id, street_name: street_name,
                            street_number: street_number, building: building, floor: floor,
                            floor_office: floor_office, zipcode_id: zipcode_id, town_id: town_id,
                            province_id: province_id, country_id: country_id, phone: phone,
                            extension: _entity.extension, fax: fax, cellular: cellular,
                            email: email, shared_contact_type_id: 2, region_id: region_id,
                            organization_id: organization_id, updated_by: updated_by }
    _contact.save
    return _contact
  end
end
