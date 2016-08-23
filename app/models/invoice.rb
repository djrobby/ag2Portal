class Invoice < ActiveRecord::Base
  belongs_to :bill
  belongs_to :invoice_status
  belongs_to :invoice_type
  belongs_to :tariff_scheme
  belongs_to :invoice_operation
  belongs_to :biller, :class_name => “Company”
  belongs_to :original_invoice, :class_name => “Invoice”
  belongs_to :billing_period
  belongs_to :reading_1, class: Reading #lectura base de cálculo de consumo
  belongs_to :reading_2, class: Reading #lectura del periodo facturado
  belongs_to :charge_account

  has_many :invoice_items
  has_many :client_payments

#nuevos belongs
#....



  attr_accessible :invoice_no, :bill_id, :invoice_status_id, :invoice_type_id, :invoice_date, :tariff_scheme_id, :company_id

  #
  # Calculated fields
  #

  def tax_breakdown

    invoice_items.group_by{|i| i.tax_type_id}.map do |t|
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

  def quantity
    invoice_items.sum("quantity")
  end
end
