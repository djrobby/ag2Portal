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
  attr_accessible :fiscal_id, :name, :supplier_code,
                  :street_type_id, :street_name, :street_number, :building, :floor, :floor_office,
                  :zipcode_id, :town_id, :province_id, :phone, :fax, :cellular, :email,
                  :region_id, :country_id, :payment_method_id, :ledger_account, :discount_rate,
                  :active, :max_orders_count, :max_orders_sum, :contract_number, :remarks,
                  :created_by, :updated_by, :entity_id, :organization_id
  attr_accessible :activity_ids

  has_many :supplier_contacts, dependent: :destroy
  has_many :purchase_prices, dependent: :destroy
  has_many :products, :through => :purchase_prices
  has_many :receipt_notes
  has_many :purchase_orders
  has_many :offer_request_suppliers
  has_many :offers
  has_many :supplier_invoices
  has_many :supplier_payments
  
  has_paper_trail

  validates :name,            :presence => true
  validates :supplier_code,   :presence => true,
                              :length => { :is => 10 },
                              :format => { with: /\A\d+\Z/, message: :code_invalid },
                              :uniqueness => { :scope => :organization_id }
  validates :fiscal_id,       :presence => true,
                              :length => { :minimum => 9 },
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

  before_validation :fields_to_uppercase

  before_destroy :check_for_dependent_records

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

  def full_code
    # Supplier code (Main activity id & sequential number) => AAAA-NNNNNN
    supplier_code.blank? ? "" : supplier_code[0..3] + '-' + supplier_code[4..9]
  end

  #
  # Calculated fields
  #
  def active_yes_no
    active ? 'Yes' : 'No'
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
end
