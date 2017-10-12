#
# ES: Facturas de abono (notas de crédito)
#
class InvoiceCredit < ActiveRecord::Base
  include ModelsModule

  belongs_to :invoice
  belongs_to :organization
  belongs_to :project
  belongs_to :client
  belongs_to :subscriber
  belongs_to :billing_period
  belongs_to :invoice_type

  attr_accessible :invoice_id, :organization_id, :project_id,
                  :client_id, :subscriber_id, :billing_period_id,
                  :invoice_no, :invoice_date, :invoice_type_id,
                  :subtotal, :taxes, :bonus, :taxable, :total,
                  :original_invoice_id

  def to_label
    "#{full_name}"
  end

  def full_name
    full_name = ""
    if !self.invoice_no.blank?
      full_name += full_no
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
    full_name
  end

  def full_no
    # Invoice no (Invoice code & year & sequential number) => SSSSS-YYYY-NNNNNNN
    invoice_no.blank? ? "" : invoice_no[0..4] + '-' + invoice_no[5..8] + '-' + invoice_no[9..15]
  end
end
