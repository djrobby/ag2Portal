class Client < ActiveRecord::Base
  belongs_to :entity
  belongs_to :street_type
  belongs_to :zipcode
  belongs_to :town
  belongs_to :province
  belongs_to :region
  belongs_to :country
  belongs_to :organization
  belongs_to :ledger_account
  belongs_to :payment_method
  belongs_to :shared_contact
  attr_accessible :active, :building, :cellular, :client_code, :email, :fax, :fiscal_id, :floor, :floor_office,
                  :first_name, :last_name, :company, :phone, :remarks, :street_name, :street_number, :organization_id,
                  :entity_id, :street_type_id, :zipcode_id, :town_id, :province_id, :region_id, :country_id,
                  :created_by, :updated_by, :is_contact, :shared_contact_id, :ledger_account_id, :payment_method_id

  has_many :delivery_notes
  has_many :sale_offers
  has_many :client_bank_accounts, dependent: :destroy
  has_many :subscribers
  has_many :bills
  has_many :invoices, through: :bills
  has_many :client_payments
  has_many :invoice_debts
  has_many :water_supply_contracts
  has_many :water_connection_contracts
  has_many :cancelled_invoices
  has_many :active_invoices
  has_many :active_supply_invoices
  has_many :invoice_bills
  has_many :invoice_credits
  has_many :invoice_rebills
  has_many :supply_requests, :through => :water_supply_contracts, :source => :contracting_request
  has_many :connection_requests, :through => :water_connection_contracts, :source => :contracting_request
  has_many :client_ledger_accounts, dependent: :destroy

  # Nested attributes
  accepts_nested_attributes_for :client_ledger_accounts,
                                :reject_if => :all_blank,
                                :allow_destroy => true

  has_paper_trail

  validates_associated :client_ledger_accounts

  validates :first_name,    :presence => true, :if => "company.blank?"
  validates :last_name,     :presence => true, :if => "company.blank?"
  validates :company,       :presence => true, :if => "last_name.blank?"
  validates :client_code,   :presence => true,
                            :length => { :is => 11 },
                            :format => { with: /\A\d+\Z/, message: :code_invalid },
                            :uniqueness => { :scope => :organization_id }
  validates :fiscal_id,     :presence => true,
                            :length => { :minimum => 8 },
                            :uniqueness => { :scope => :organization_id }
  validates :street_type,   :presence => true
  validates :zipcode,       :presence => true
  validates :town,          :presence => true
  validates :province,      :presence => true
  validates :region,        :presence => true
  validates :country,       :presence => true
  validates :entity,        :presence => true
  validates :organization,  :presence => true
  validates :payment_method,:presence => true

  # Scopes
  scope :by_code, -> { order(:client_code) }
  #
  scope :belongs_to_organization, -> organization { where("organization_id = ?", organization).by_code }

  # Callbacks
  before_validation :fields_to_uppercase
  before_destroy :check_for_dependent_records
  after_create :should_create_shared_contact, if: :is_contact?
  after_update :should_update_shared_contact, if: :is_contact?

  def active_bank_accounts?
    !client_bank_accounts.where(ending_at: nil).blank?
  end

  def active_bank_account
    client_bank_accounts.where(ending_at: nil).order(:starting_at).last
  end

  def fields_to_uppercase
    if !self.fiscal_id.blank?
      self[:fiscal_id].upcase!
    end
    if !self.client_code.blank?
      self[:client_code].upcase!
    end
    true
  end

  def to_label
    if !self.last_name.blank? && !self.first_name.blank?
      "#{full_name_and_code}"
    else
      "#{full_code} #{company}"
    end
  end

  def to_name
    if !self.last_name.blank? && !self.first_name.blank?
      "#{full_name}"
    else
      "#{company}"
    end
  end

  def full_name
    full_name = ""
    if !self.last_name.blank?
      full_name += self.last_name
    end
    if !self.first_name.blank?
      full_name += ", " + self.first_name
    end
    full_name[0,40]
  end

  def partial_name30
    full_name[0,30]
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

  def full_name_or_company_code_fiscal
    client_code + " " + full_name_or_company + " " + fiscal_id
  end

  def full_code
    # Client code (Organization id & sequential number) => OOOO-NNNNNNN
    client_code.blank? || client_code == "$ERR" ? "" : client_code[0..3] + '-' + client_code[4..10]
  end

  def diput
    client_code.blank? || client_code == "$ERR" ? "" : client_code[2..3] + client_code[5..10]
  end

  def entity_first_name
    self.entity.first_name
  end

  def entity_last_name
    self.entity.last_name
  end

  def entity_company
    self.entity.company
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
  # Records navigator
  #
  def to_first
    Client.order("client_code").first
  end

  def to_prev
    Client.where("client_code < ?", client_code).order("client_code").last
  end

  def to_next
    Client.where("client_code > ?", client_code).order("client_code").first
  end

  def to_last
    Client.order("client_code").last
  end

  searchable do
    text :client_code, :full_name, :company, :fiscal_id, :street_name, :phone, :cellular, :email
    string :address, :multiple => true do
      address_1 unless address_1.blank?
    end
    string :client_code, :multiple => true
    string :company
    string :full_name
    string :fiscal_id
    integer :organization_id
    string :sort_no do
      client_code
    end
  end

  # Client code
  def self.cl_next_code(organization)
    code = ''
    organization = organization.to_s if organization.is_a? Fixnum
    organization = organization.rjust(4, '0')
    last_code = Client.where("client_code LIKE ?", "#{organization}%").order(:client_code).maximum(:client_code)
    if last_code.nil?
      code = organization + '0000001'
    else
      last_code = last_code[4..10].to_i + 1
      code = organization + last_code.to_s.rjust(7, '0')
    end
    code
  end

  private

  # Before destroy
  def check_for_dependent_records
    # Check for delivery notes
    if delivery_notes.count > 0
      errors.add(:base, I18n.t('activerecord.models.client.check_for_delivery_notes'))
      return false
    end
    # Check for sale offers
    if sale_offers.count > 0
      errors.add(:base, I18n.t('activerecord.models.client.check_for_sale_offers'))
      return false
    end
    # Check for subscribers
    if subscribers.count > 0
      errors.add(:base, I18n.t('activerecord.models.client.check_for_subscribers'))
      return false
    end
    # Check for invoices
    if bills.count > 0
      errors.add(:base, I18n.t('activerecord.models.client.check_for_client_invoices'))
      return false
    end
    if invoices.count > 0
      errors.add(:base, I18n.t('activerecord.models.client.check_for_client_invoices'))
      return false
    end
    # Check for charges
    if client_payments.count > 0
      errors.add(:base, I18n.t('activerecord.models.client.check_for_client_charges'))
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
    _contact = SharedContact.find_by_fiscal_id_organization_type(fiscal_id, organization_id, 3) rescue nil
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
      _contact = SharedContact.find_by_fiscal_id_organization_type(fiscal_id, organization_id, 3) rescue nil
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
    _contact = SharedContact.create(first_name: first_name, last_name: last_name, company: company,
                                    fiscal_id: fiscal_id, street_type_id: street_type_id, street_name: street_name,
                                    street_number: street_number, building: building, floor: floor,
                                    floor_office: floor_office, zipcode_id: zipcode_id, town_id: town_id,
                                    province_id: province_id, country_id: country_id, phone: phone,
                                    extension: _entity.extension, fax: fax, cellular: cellular,
                                    email: email, shared_contact_type_id: 3, region_id: region_id,
                                    organization_id: organization_id, created_by: created_by, updated_by: updated_by)
    return _contact
  end

  # Updates existing Shared Contact
  def update_shared_contact(_contact, _entity)
    _contact.attributes = { first_name: first_name, last_name: last_name, company: company,
                            fiscal_id: fiscal_id, street_type_id: street_type_id, street_name: street_name,
                            street_number: street_number, building: building, floor: floor,
                            floor_office: floor_office, zipcode_id: zipcode_id, town_id: town_id,
                            province_id: province_id, country_id: country_id, phone: phone,
                            extension: _entity.extension, fax: fax, cellular: cellular,
                            email: email, shared_contact_type_id: 3, region_id: region_id,
                            organization_id: organization_id, updated_by: updated_by }
    _contact.save
    return _contact
  end
end
