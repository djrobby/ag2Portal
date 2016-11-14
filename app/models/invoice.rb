class Invoice < ActiveRecord::Base
  belongs_to :bill
  belongs_to :invoice_status
  belongs_to :invoice_type
  belongs_to :invoice_operation
  belongs_to :tariff_scheme
  belongs_to :biller, :class_name => 'Company'
  belongs_to :original_invoice, :class_name => 'Invoice'
  belongs_to :billing_period
  belongs_to :charge_account

  alias_attribute :company, :biller

  attr_accessible :invoice_no, :invoice_date, :consumption, :consumption_real, :consumption_estimated, :consumption_other,
                  :discount_pct, :exemption, :payday_limit,
                  :bill_id, :invoice_status_id, :invoice_type_id, :tariff_scheme_id, :invoice_operation_id,
                  :biller_id, :original_invoice_id, :billing_period_id, :charge_account_id,
                  :created_by, :updated_by, :reading_1_date, :reading_2_date, :reading_1_index, :reading_2_index

  has_many :invoice_items, dependent: :destroy
  has_many :client_payments

  before_validation :item_repeat, :on => :create
  after_save :bill_status
  before_create :assign_payday_limit

  def invoiced_concepts
    _codes = ""
    _ii = invoice_items.group(:code)
    _ii.each do |r|
      if _codes == ""
        _codes += r.code
      else
        _codes += ("-" + r.code)
      end
    end
    _codes
  end

  #
  # Calculated fields
  #
  def unpaid?
    if payday_limit.nil?
      false
    else
      payday_limit < Date.today
    end
  end

  def reading_1
    bill.reading_1
  end

  def reading_2
    bill.reading_2
  end

  def reading_1_id
    bill.try(:reading_1).try(:id)
  end

  def reading_2_id
    bill.try(:reading_2).try(:id)
  end

  def tax_breakdown
    invoice_items.group_by{|i| i.tax_type_id}.map do |t|
      tax = t[0].nil? ? 0 : TaxType.find(t[0]).tax
      sum_total = t[1].sum{|invoice_item| invoice_item.amount}
      tax_total = sum_total * (tax/100)
      [tax, sum_total, tax_total ,t[1].count]
    end
  end

  def breakdown
    invoice_items.group_by{|i| i.tax_type_id}.map do |t|
      tax = t[0].nil? ? nil : TaxType.find(t[0])
      sum_total = t[1].sum{|j| j.amount}
      tax_total = sum_total * (tax/100)
      [tax.try(:id), sum_total, tax_total ,t[1].count]
    end
  end

  def net_tax
    tax_breakdown.sum{|t| t[2]}
  end

  def subtotal
    tax_breakdown.sum{|t| t[1]}
  end

  def bonus
    (discount_pct / 100) * subtotal
  end

  def taxable
    subtotal - bonus
  end

  def taxes
    tax_breakdown.sum{|t| t[2]}
  end

  def total
    taxes + taxable
  end

  def receivable
    total - exemption
  end

  def collected
    client_payments.sum("amount")
  end

  def debt
    receivable-collected
  end

  def quantity
    invoice_items.sum("quantity")
  end

  def collected
    client_payments.sum("amount")
  end

  private

  def item_repeat
    @errors.add(:base, "Invoice repeat") if !Invoice.where(bill_id: bill_id, invoice_type_id: invoice_type_id, invoice_operation_id: invoice_operation_id, billing_period_id: billing_period_id, biller_id: biller_id).blank?
  end

  def bill_status
    b = self.bill
    b.update_attributes(invoice_status_id: b.invoices.map(&:invoice_status_id).min)
  end

  def assign_payday_limit
    self.payday_limit = self.invoice_date if self.payday_limit.nil?
  end

end
