class InvoiceTax < ActiveRecord::Base
  belongs_to :invoice
  belongs_to :tax_type
  attr_accessible :description, :items_qty, :tax, :tax_amount, :taxable,
                  :invoice_id, :tax_type_id

  # Scopes
  scope :by_invoice_id, -> i {
    where("invoice_taxes.invoice_id = #{i} AND invoice_taxes.tax <> 0")
    .select("invoice_taxes.invoice_id invoice_id_, invoice_taxes.id invoice_tax_id_,
             invoice_taxes.tax_type_id tax_type_id_, invoice_taxes.description description_,
             invoice_taxes.tax tax_, invoice_taxes.taxable taxable_,
             invoice_taxes.tax_amount tax_amount_, invoice_taxes.items_qty items_qty_")
    .order('invoice_taxes.id')
  }
end
