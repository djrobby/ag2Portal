class PreInvoiceItem < ActiveRecord::Base
  belongs_to :pre_invoice
  belongs_to :tariff
  belongs_to :tax_type
  belongs_to :product
  belongs_to :measure

  attr_accessible :code, :subcode, :description, :quantity, :price, :discount, :discount_pct,
                  :invoice_id, :tariff_id, :tax_type_id, :product_id, :measure_id

  #
  # Calculated fields
  #
  def net_price
    price - discount
  end

  def amount
    quantity * net_price
  end

  # def tax
  #   tax_type.nil? ? 0 : (tax_type.tax / 100) * amount
  # end

  def net
    amount - bonus
  end

  # def net_tax
  #   tax - (tax * (discount_pct / 100)) if !discount_pct.blank?
  # end

  def total
    net #+ net_tax
  end

  def bonus
    (discount_pct / 100) * amount if !discount_pct.blank?
  end
end
