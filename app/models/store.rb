class Store < ActiveRecord::Base
  belongs_to :company
  belongs_to :office
  belongs_to :organization
  belongs_to :supplier
  attr_accessible :location, :name, :company_id, :office_id,
                  :organization_id, :supplier_id

  has_many :stocks
  has_many :products, :through => :stocks
  has_many :work_orders
  has_many :work_order_items
  has_many :receipt_notes
  has_many :receipt_note_items
  has_many :delivery_notes
  has_many :delivery_note_items
  has_many :purchase_orders
  has_many :purchase_order_items
  has_many :offer_requests
  has_many :offer_request_items
  has_many :offers
  has_many :offers_items
  has_many :sale_offers
  has_many :sale_offer_items

  has_paper_trail

  validates :name,      :presence => true
  validates :company,   :presence => true, :if => "supplier.blank?"
  validates :supplier,  :presence => true, :if => "company.blank?"

  before_destroy :check_for_dependent_records

  #
  # Calculated fields
  #
  def stock
    stocks.sum("current")
  end

  private

  def check_for_dependent_records
    # Check for stocks
    if stocks.count > 0
      errors.add(:base, I18n.t('activerecord.models.store.check_for_stocks'))
      return false
    end
    # Check for work orders
    if work_orders.count > 0
      errors.add(:base, I18n.t('activerecord.models.store.check_for_work_orders'))
      return false
    end
    # Check for work order items
    if work_order_items.count > 0
      errors.add(:base, I18n.t('activerecord.models.store.check_for_work_orders'))
      return false
    end
    # Check for receipt notes
    if receipt_notes.count > 0
      errors.add(:base, I18n.t('activerecord.models.store.check_for_receipt_notes'))
      return false
    end
    # Check for receipt note items
    if receipt_note_items.count > 0
      errors.add(:base, I18n.t('activerecord.models.store.check_for_receipt_notes'))
      return false
    end
    # Check for delivery notes
    if delivery_notes.count > 0
      errors.add(:base, I18n.t('activerecord.models.store.check_for_delivery_notes'))
      return false
    end
    # Check for delivery note items
    if delivery_note_items.count > 0
      errors.add(:base, I18n.t('activerecord.models.store.check_for_delivery_notes'))
      return false
    end
    # Check for purchase orders
    if purchase_orders.count > 0
      errors.add(:base, I18n.t('activerecord.models.store.check_for_purchase_orders'))
      return false
    end
    # Check for purchase order items
    if purchase_order_items.count > 0
      errors.add(:base, I18n.t('activerecord.models.store.check_for_purchase_orders'))
      return false
    end
    # Check for offer requests
    if offer_requests.count > 0
      errors.add(:base, I18n.t('activerecord.models.store.check_for_offer_requests'))
      return false
    end
    # Check for offer request items
    if offer_request_items.count > 0
      errors.add(:base, I18n.t('activerecord.models.store.check_for_offer_requests'))
      return false
    end
    # Check for offers
    if offers.count > 0
      errors.add(:base, I18n.t('activerecord.models.store.check_for_offers'))
      return false
    end
    # Check for offer items
    if offer_items.count > 0
      errors.add(:base, I18n.t('activerecord.models.store.check_for_offers'))
      return false
    end
    # Check for sale offers
    if sale_offers.count > 0
      errors.add(:base, I18n.t('activerecord.models.store.check_for_sale_offers'))
      return false
    end
    # Check for sale offer items
    if sale_offer_items.count > 0
      errors.add(:base, I18n.t('activerecord.models.store.check_for_sale_offers'))
      return false
    end
  end
end
