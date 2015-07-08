class SupplierInvoiceDebt < ActiveRecord::Base
  include ModelsModule
  
  belongs_to :supplier_invoice
  belongs_to :organization
  belongs_to :supplier
  attr_accessible :supplier_invoice_id, :organization_id, :supplier_id,
                  :invoice_no, :subtotal, :taxes, :bonus, :taxable, :total, :paid, :debt

  def to_label
    "#{full_name}"
  end

  def full_name
    full_name = ""
    if !self.invoice_no.blank?
      full_name += self.invoice_no
    end
    if !self.supplier_invoice.invoice_date.blank?
      full_name += " " + formatted_date(self.supplier_invoice.invoice_date)
    end
    if !self.supplier_invoice.supplier.blank?
      full_name += " " + self.supplier_invoice.supplier.full_name
    end
    if !self.total.blank?
      full_name += ": " + formatted_number(self.total, 2)
    end
    if !self.paid.blank?
      full_name += " - " + formatted_number(self.paid, 2)
    end
    if !self.debt.blank?
      full_name += " - " + formatted_number(self.debt, 2)
    end
    full_name
  end
end
