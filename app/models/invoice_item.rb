class InvoiceItem < ActiveRecord::Base
  belongs_to :invoice
  belongs_to :tariff
  belongs_to :tax_type
  belongs_to :product
  belongs_to :measure

  attr_accessible :code, :subcode, :description, :quantity, :price, :discount, :discount_pct,
                  :invoice_id, :tariff_id, :tax_type_id, :product_id, :measure_id, :created_by, :updated_by

  before_validation :item_repeat, :on => :create

  #
  # Calculated fields
  #
  def discount_present?
    !discount.blank? && discount != 0
  end

  def net_price
    price - discount
  end

  def amount
    quantity * net_price
  end

  def bonus
    (discount_pct / 100) * amount if !discount_pct.blank?
  end

  def net
    amount - bonus
  end

  def tax
    tax_type.nil? ? 0 : (tax_type.tax / 100) * amount
  end

  def total
    net + tax
  end

  private
  def item_repeat
    @errors.add(:base, "Item repeat") if !InvoiceItem.where(invoice_id: invoice_id, tariff_id: tariff_id, code: code, subcode: subcode).blank?
  end

end
