class ReceiptNoteItem < ActiveRecord::Base
  belongs_to :receipt_note
  belongs_to :purchase_order
  belongs_to :purchase_order_item
  belongs_to :product
  belongs_to :tax_type
  belongs_to :store
  belongs_to :work_order
  belongs_to :charge_account
  attr_accessible :code, :description, :discount, :discount_pct, :price, :quantity,
                  :receipt_note_id, :purchase_order_id, :purchase_order_item_id,
                  :product_id, :tax_type_id, :store_id, :work_order_id, :charge_account_id

  has_many :supplier_invoice_items

  has_paper_trail

  validates :receipt_note,   :presence => true
  validates :description,    :presence => true
  validates :product,        :presence => true
  validates :tax_type,       :presence => true
  validates :store,          :presence => true
  validates :work_order,     :presence => true
  validates :charge_account, :presence => true

  before_destroy :check_for_dependent_records

  private

  def check_for_dependent_records
    # Check for supplier invoice items
    if supplier_invoice_items.count > 0
      errors.add(:base, I18n.t('activerecord.models.receipt_note_item.check_for_supplier_invoices'))
      return false
    end
  end
end
