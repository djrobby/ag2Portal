class PreInvoiceItem < ActiveRecord::Base
  belongs_to :pre_invoice
  belongs_to :tariff
  belongs_to :tax_type
  belongs_to :product
  belongs_to :measure

  attr_accessible :code, :subcode, :description, :quantity, :price, :discount, :discount_pct,
                  :tariff_id, :tax_type_id, :product_id, :measure_id, :pre_invoice_id

  #
  # Calculated fields
  #
  def subcode_name
    _subcode = " "
      if subcode == "CF"
            _subcode = I18n.t("activerecord.attributes.invoice_item.cf")
          elsif subcode == "CV"
            _subcode = I18n.t("activerecord.attributes.invoice_item.cv")
          elsif subcode == "VP"
            _subcode = I18n.t("activerecord.attributes.invoice_item.vp")
          elsif subcode == "BL1"
            _subcode = I18n.t("activerecord.attributes.invoice_item.bl1")
          elsif subcode == "BL2"
            _subcode = I18n.t("activerecord.attributes.invoice_item.bl2")
          elsif subcode == "BL3"
            _subcode = I18n.t("activerecord.attributes.invoice_item.bl3")
          elsif subcode == "BL4"
            _subcode = I18n.t("activerecord.attributes.invoice_item.bl4")
          elsif subcode == "BL5"
            _subcode = I18n.t("activerecord.attributes.invoice_item.bl5")
          elsif subcode == "BL6"
            _subcode = I18n.t("activerecord.attributes.invoice_item.bl6")
          elsif subcode == "BL7"
            _subcode = I18n.t("activerecord.attributes.invoice_item.bl7")
          elsif subcode == "BL8"
            _subcode = I18n.t("activerecord.attributes.invoice_item.bl8")
      end
      _subcode
  end

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
