#
# ES: Saldos vivos de factura (todas las facturas con deuda actual, originales, abonos y refacturas)
#
class InvoiceCurrentDebt < ActiveRecord::Base
  include ModelsModule

  belongs_to :invoice
  belongs_to :organization
  belongs_to :client
  belongs_to :subscriber
  belongs_to :bill
  belongs_to :project
  belongs_to :office
  attr_accessible :invoice_id, :organization_id, :client_id, :subscriber_id, :bill_id, :project_id, :office_id,
                  :invoice_no, :invoice_date, :payday_limit,
                  :subtotal, :taxes, :bonus, :taxable, :total, :paid, :calc_debt, :totals, :receivables, :debt

  # Scopes
  scope :by_no, -> { order(:invoice_no) }
  #
  scope :g_where, -> w {
    where(w).by_no
  }
  # scope :g_where, -> w {
  #   joins(:bill)
  #   .where(w)
  #   .by_no
  # }

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
    if !self.invoice_date.blank?
      full_name += " " + formatted_date(self.invoice_date)
    end
    if !self.invoice.client.blank?
      full_name += " " + self.invoice.client.full_name
    end
    if !self.receivables.blank?
      full_name += ": " + formatted_number(self.receivables, 2)
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
