class TaxType < ActiveRecord::Base
  belongs_to :input_ledger_account, class_name: "LedgerAccount"
  belongs_to :output_ledger_account, class_name: "LedgerAccount"

  attr_accessible :description, :tax, :expiration,
                  :created_by, :updated_by,
                  :input_ledger_account_id, :output_ledger_account_id

  has_many :products
  has_many :work_order_items
  has_many :receipt_note_items
  has_many :delivery_note_items
  has_many :purchase_order_items
  has_many :offer_request_items
  has_many :offer_items
  has_many :supplier_invoice_items
  has_many :sale_offer_items

  has_paper_trail

  validates :description, :presence => true
  validates :tax,         :presence => true

  # Scopes
  scope :current, -> { where("expiration >= ? OR expiration IS NULL", Date.today).order('tax') }
  scope :expired, -> { where("NOT expiration IS NULL AND expiration < ?", Date.today).order('tax') }

  before_destroy :check_for_dependent_records

  def to_label
    "#{description} (#{tax})"
  end

  #
  # Class (self) user defined methods
  #
  def self.exempt
    _tt = nil
    # current & 0
    _tt = TaxType.where('(expiration >= ? OR expiration IS NULL) AND tax = 0', Date.today).first
    # if current does not exist, expired & 0
    _tt = _tt.nil? ? TaxType.where('(NOT expiration IS NULL AND expiration < ?) AND tax = 0', Date.today).first : _tt
  end

  def self.exempt_id
    self.exempt || 0
  end

  private

  def check_for_dependent_records
    # Check for products
    if products.count > 0
      errors.add(:base, I18n.t('activerecord.models.tax_type.check_for_products'))
      return false
    end
    # Check for work order items
    if work_order_items.count > 0
      errors.add(:base, I18n.t('activerecord.models.tax_type.check_for_work_orders'))
      return false
    end
    # Check for purchase order items
    if purchase_order_items.count > 0
      errors.add(:base, I18n.t('activerecord.models.tax_type.check_for_purchase_orders'))
      return false
    end
    # Check for receipt note items
    if receipt_note_items.count > 0
      errors.add(:base, I18n.t('activerecord.models.tax_type.check_for_receipt_notes'))
      return false
    end
    # Check for offer request items
    if offer_request_items.count > 0
      errors.add(:base, I18n.t('activerecord.models.tax_type.check_for_offer_requests'))
      return false
    end
    # Check for offer items
    if offer_items.count > 0
      errors.add(:base, I18n.t('activerecord.models.tax_type.check_for_offers'))
      return false
    end
    # Check for delivery note items
    if delivery_note_items.count > 0
      errors.add(:base, I18n.t('activerecord.models.tax_type.check_for_delivery_notes'))
      return false
    end
    # Check for supplier invoice items
    if supplier_invoice_items.count > 0
      errors.add(:base, I18n.t('activerecord.models.tax_type.check_for_supplier_invoices'))
      return false
    end
    # Check for client invoice items
    if supplier_invoice_items.count > 0
      errors.add(:base, I18n.t('activerecord.models.tax_type.check_for_client_invoices'))
      return false
    end
    # Check for sale offer items
    if sale_offer_items.count > 0
      errors.add(:base, I18n.t('activerecord.models.tax_type.check_for_sale_offers'))
      return false
    end
  end
end
