class InvoiceDebt < ActiveRecord::Base
  include ModelsModule

  belongs_to :invoice
  belongs_to :organization
  belongs_to :client
  belongs_to :subscriber
  attr_accessible :invoice_id, :organization_id, :client_id, :subscriber_id,
                  :invoice_no, :subtotal, :taxes, :bonus, :taxable, :total, :paid, :debt

  def to_label
    "#{full_name}"
  end

  def self.unpaid
    where('debt > 0')
  end

  def full_name
    full_name = ""
    if !self.invoice_no.blank?
      full_name += self.invoice_no
    end
    if !self.invoice.invoice_date.blank?
      full_name += " " + formatted_date(self.invoice.invoice_date)
    end
    if !self.invoice.client.blank?
      full_name += " " + self.invoice.client.full_name
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
