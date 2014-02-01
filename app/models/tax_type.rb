class TaxType < ActiveRecord::Base
  attr_accessible :description, :tax, :expiration,
                  :created_by, :updated_by

  has_many :products
  has_many :work_order_items
  has_many :receipt_note_items
  has_many :delivery_note_items
  has_many :purchase_order_items
  has_many :offer_request_items
  has_many :offer_items
  has_many :supplier_invoice_items

  has_paper_trail

  validates :description, :presence => true
  validates :tax,         :presence => true

  before_destroy :check_for_dependent_records

  def to_label
    "#{description} (#{tax})"
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
  end
end
