class PreInvoice < ActiveRecord::Base
  belongs_to :pre_bill
  belongs_to :invoice_status
  belongs_to :invoice_type
  belongs_to :invoice_operation
  belongs_to :tariff_scheme
  belongs_to :biller, :class_name => 'Company'
  belongs_to :billing_period
  belongs_to :reading_1, :class_name => 'Reading' #lectura base de cálculo de consumo
  belongs_to :reading_2, :class_name => 'Reading' #lectura del periodo facturado
  belongs_to :charge_account
  belongs_to :invoice

  attr_accessible :invoice_no, :invoice_date, :consumption, :consumption_real, :consumption_estimated, :consumption_other,
                  :discount_pct, :exemption, :confirmation_date,
                  :pre_bill_id, :invoice_status_id, :invoice_type_id, :tariff_scheme_id, :invoice_operation_id,
                  :biller_id, :billing_period_id, :reading_1_id, :reading_2_id, :charge_account_id, :invoice_id,
                  :payday_limit

  has_many :pre_invoice_items, dependent: :destroy

  alias_attribute :company, :biller

  #
  # Calculated fields
  #

  def tax_breakdown
    pre_invoice_items.group_by{|i| i.tax_type_id}.map do |t|
      tax = t[0].nil? ? 0 : TaxType.find(t[0]).tax
      sum_total = t[1].sum{|j| j.total}
      tax_total = sum_total * (tax/100)
      [tax, sum_total, tax_total ,t[1].count]
    end
  end

  def net_tax
    tax_breakdown.sum{|t| t[2]}
  end

  def subtotal
    subtotal = 0
    pre_invoice_items.each do |i|
      if !i.total.blank?
        subtotal += i.total
      end
    end
    subtotal
  end

  def bonus
    bonus = 0
    pre_invoice_items.each do |i|
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
    pre_invoice_items.each do |i|
      if !i.net_tax.blank?
        taxes += i.net_tax
      end
    end
    taxes
  end

  def total
    net_tax + subtotal
  end

  def quantity
    pre_invoice_items.sum("quantity")
  end
end
