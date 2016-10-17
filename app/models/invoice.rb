class Invoice < ActiveRecord::Base
  belongs_to :bill
  belongs_to :invoice_status
  belongs_to :invoice_type
  belongs_to :invoice_operation
  belongs_to :tariff_scheme
  belongs_to :biller, :class_name => 'Company'
  belongs_to :original_invoice, :class_name => 'Invoice'
  belongs_to :billing_period
  belongs_to :reading_1, :class_name => 'Reading' #lectura base de cálculo de consumo
  belongs_to :reading_2, :class_name => 'Reading' #lectura del periodo facturado
  belongs_to :charge_account

  alias_attribute :company, :biller

  attr_accessible :invoice_no, :invoice_date, :consumption, :consumption_real, :consumption_estimated, :consumption_other,
                  :discount_pct, :exemption, :payday_limit,
                  :bill_id, :invoice_status_id, :invoice_type_id, :tariff_scheme_id, :invoice_operation_id,
                  :biller_id, :original_invoice_id, :billing_period_id, :reading_1_id, :reading_2_id, :charge_account_id,
                  :created_by, :updated_by

  has_many :invoice_items, dependent: :destroy
  has_many :client_payments

  before_validation :item_repeat, :on => :create
  after_save :bill_status
  #
  # Calculated fields
  #
  def reading_1_date
    reading_1.reading_date
  end

  def reading_2_date
    reading_2.reading_date
  end

  def reading_1_index
    reading_1.reading_index
  end

  def reading_2_index
    reading_2.reading_index
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
    subtotal = 0
    invoice_items.each do |i|
      if !i.total.blank?
        subtotal += i.total
      end
    end
    subtotal
  end

  def bonus
    bonus = 0
    invoice_items.each do |i|
      if !i.bonus.blank?
        bonus += i.bonus
      end
    end
    bonus
  end

  def taxable
    subtotal - bonus
  end

  def taxes
    taxes = 0
    invoice_items.each do |i|
      if !i.net_tax.blank?
        taxes += i.net_tax
      end
    end
    taxes
  end

  def total
    net_tax + subtotal
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
    @errors.add(:base, "Invoice repeat") if !Invoice.where(bill_id: bill_id, invoice_type_id: invoice_type_id, invoice_operation_id: invoice_operation_id, billing_period_id: billing_period_id).blank?
  end

  def bill_status
    b = self.bill
    b.update_attributes(invoice_status_id: b.invoices.map(&:invoice_status_id).min)
  end

end
