class DeliveryNoteItem < ActiveRecord::Base
  belongs_to :delivery_note
  belongs_to :sale_offer
  belongs_to :sale_offer_item
  belongs_to :product
  belongs_to :tax_type
  belongs_to :store
  belongs_to :work_order
  belongs_to :charge_account
  belongs_to :project
  attr_accessible :cost, :description, :discount, :discount_pct, :price, :quantity,
                  :delivery_note_id, :sale_offer_id, :sale_offer_item_id, :product_id,
                  :tax_type_id, :store_id, :work_order_id, :charge_account_id, :project_id

  has_many :client_invoice_items

  has_paper_trail

  validates :delivery_note,   :presence => true
  validates :description,     :presence => true,
                              :length => { :maximum => 40 }
  validates :product,         :presence => true
  validates :tax_type,        :presence => true
  validates :store,           :presence => true
  validates :work_order,      :presence => true
  validates :charge_account,  :presence => true
  validates :project,         :presence => true

  before_destroy :check_for_dependent_records
  before_validation :fields_to_uppercase

  def fields_to_uppercase
    if !self.description.blank?
      self[:description].upcase!
    end
  end

  #
  # Calculated fields
  #
  def costs
    quantity * cost
  end

  def amount
    quantity * (price - discount)
  end

  def tax
    (tax_type.tax / 100) * amount if !tax_type.nil?
  end

  def net
    amount - (amount * (delivery_note.discount_pct / 100)) if !delivery_note.discount_pct.blank?
  end

  def net_tax
    tax - (tax * (delivery_note.discount_pct / 100)) if !delivery_note.discount_pct.blank?
  end

  private

  def check_for_dependent_records
    # Check for client invoice items
    if client_invoice_items.count > 0
      errors.add(:base, I18n.t('activerecord.models.delivery_note_item.check_for_client_invoices'))
      return false
    end
  end
end
