class SupplierInvoiceItem < ActiveRecord::Base
  belongs_to :supplier_invoice
  belongs_to :receipt_note
  belongs_to :receipt_note_item
  belongs_to :product
  belongs_to :tax_type
  belongs_to :work_order
  belongs_to :charge_account
  attr_accessible :code, :description, :discount, :discount_pct, :price, :quantity,
                  :supplier_invoice_id, :receipt_note_id, :receipt_note_item_id,
                  :product_id, :tax_type_id, :work_order_id, :charge_account_id

  has_paper_trail

  validates :supplier_invoice,  :presence => true
  validates :description,       :presence => true
  validates :product,           :presence => true
  validates :tax_type,          :presence => true
  validates :work_order,        :presence => true
  validates :charge_account,    :presence => true
end
