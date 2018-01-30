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
  belongs_to :invoice_status
  belongs_to :invoice_type
  belongs_to :invoice_operation
  attr_accessible :invoice_id, :organization_id, :client_id, :subscriber_id, :bill_id, :project_id, :office_id,
                  :invoice_status_id, :invoice_type_id, :invoice_operation_id, :invoice_no, :invoice_date, :payday_limit,
                  :subtotal, :taxes, :bonus, :taxable, :total, :paid, :calc_debt, :totals, :receivables, :debt
  delegate :id, :to => :invoice, :allow_nil => true
  delegate :billing_period_id, :to => :invoice, :allow_nil => true
  delegate :biller_id, :to => :invoice, :allow_nil => true

  has_many :debt_claim_items, through: :invoice

  # Scopes
  scope :by_no, -> { order(:invoice_no) }
  scope :by_project_bill_invoice, -> { order(:project_id, :bill_id, :invoice_id) }
  #
  scope :unpaid, -> { where("invoice_status_id = 1 AND payday_limit < ?", Date.today).by_project_bill_invoice }
  scope :unpaid_and_unclaimed, -> {
    joins('LEFT JOIN debt_claim_items ON invoice_current_debts.invoice_id=debt_claim_items.invoice_id')
    .where('debt_claim_items.invoice_id IS NULL AND invoice_current_debts.invoice_status_id = 1 AND invoice_current_debts.payday_limit < ?', Date.today)
    .by_project_bill_invoice
  }
  scope :unpaid_and_claimed, -> {
    joins(:debt_claim_items).where('invoice_current_debts.invoice_status_id = 1 AND invoice_current_debts.payday_limit < ?', Date.today)
    .by_project_bill_invoice
  }
  scope :unclaimed, -> {
    joins('LEFT JOIN debt_claim_items ON invoice_current_debts.invoice_id=debt_claim_items.invoice_id')
    .where('debt_claim_items.invoice_id IS NULL').by_project_bill_invoice
  }
  scope :claimed, -> { joins(:debt_claim_items).by_project_bill_invoice }
  #
  scope :commercial, -> { where("invoice_type_id != 1 AND invoice_type_id != 3").by_no }
  scope :service, -> { where(invoice_type_id: InvoiceType::WATER).by_no }
  scope :contracting, -> { where(invoice_type_id: InvoiceType::CONTRACT).by_no }
  #
  scope :g_where, -> w {
    joins('LEFT JOIN subscribers ON invoice_current_debts.subscriber_id = subscribers.id')
    .where(w).by_project_bill_invoice
  }
  scope :g_where_and_unclaimed, -> w {
    joins(:invoice)
    .joins('LEFT JOIN debt_claim_items ON invoice_current_debts.invoice_id=debt_claim_items.invoice_id')
    .joins('LEFT JOIN subscribers ON invoice_current_debts.subscriber_id = subscribers.id')
    .where('debt_claim_items.invoice_id IS NULL AND invoice_current_debts.invoice_status_id = 1 AND invoice_current_debts.payday_limit < ?', Date.today)
    .where(w).by_project_bill_invoice
  }

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
