class SupplierInvoiceDebt < ActiveRecord::Base
  belongs_to :supplier_invoice
  attr_accessible :supplier_invoice_id, :organization_id, :invoice_no, :subtotal, :taxes, :bonus, :taxable, :total, :paid, :debt
end
