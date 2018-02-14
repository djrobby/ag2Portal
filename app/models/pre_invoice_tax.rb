class PreInvoiceTax < ActiveRecord::Base
  belongs_to :pre_invoice
  belongs_to :tax_type
  attr_accessible :description, :items_qty, :tax, :tax_amount, :taxable,
                  :pre_invoice_id, :tax_type_id
end
