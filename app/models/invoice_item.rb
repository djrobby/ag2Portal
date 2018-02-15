class InvoiceItem < ActiveRecord::Base
  include ModelsModule

  @@block_codes = ["BL1", "BL2", "BL3", "BL4", "BL5", "BL6", "BL7", "BL8"]

  belongs_to :invoice
  belongs_to :tariff
  belongs_to :tax_type
  belongs_to :product
  belongs_to :measure
  belongs_to :sale_offer
  belongs_to :sale_offer_item
  belongs_to :charge_account
  attr_accessor :thing
  attr_accessible :code, :subcode, :description, :quantity, :price, :discount, :discount_pct,
                  :invoice_id, :tariff_id, :tax_type_id, :product_id, :measure_id,
                  :sale_offer_id, :sale_offer_item_id, :charge_account_id,
                  :created_by, :updated_by, :thing

  has_paper_trail

  validates :code,                :presence => true
  validates :description,         :presence => true,
                                  :length => { :maximum => 40 }
  validates :tariff,              :presence => true, :if => "product_id.blank?"
  validates :product,             :presence => true, :if => "tariff_id.blank?"
  validates :tax_type,            :presence => true
  validates :quantity,            :numericality => true
  validates :price,               :numericality => true
  validates :sale_offer_item,     :presence => true, :if => "!sale_offer_id.blank?"

  # Scopes
  scope :by_invoice_ids, -> i {
    joins(:tax_type)
    .where("invoice_items.invoice_id IN (#{i})")
    .select("invoice_items.invoice_id invoice_id_, invoice_items.id invoice_item_id_,
             invoice_items.code code_, invoice_items.subcode subcode_, invoice_items.description description_,
             invoice_items.quantity quantity_, invoice_items.price price_,
             tax_types.tax tax_type_tax_, invoice_items.discount discount_, invoice_items.discount_pct discount_pct_,
             (invoice_items.price - invoice_items.discount) net_price_,
             ((invoice_items.price - invoice_items.discount) * invoice_items.quantity) amount_,
             CASE invoice_items.discount_pct IS NULL WHEN TRUE THEN 0 ELSE ((invoice_items.discount_pct / 100) * ((invoice_items.price - invoice_items.discount) * invoice_items.quantity)) END bonus_,
             ((invoice_items.price - invoice_items.discount) * invoice_items.quantity) - CASE invoice_items.discount_pct IS NULL WHEN TRUE THEN 0 ELSE ((invoice_items.discount_pct / 100) * ((invoice_items.price - invoice_items.discount) * invoice_items.quantity)) END net_,
             CASE tax_types.tax IS NULL WHEN TRUE THEN 0 ELSE (tax_types.tax / 100) * ((invoice_items.price - invoice_items.discount) * invoice_items.quantity) END tax_,
             ((invoice_items.price - invoice_items.discount) * invoice_items.quantity) - CASE invoice_items.discount_pct IS NULL WHEN TRUE THEN 0 ELSE ((invoice_items.discount_pct / 100) * ((invoice_items.price - invoice_items.discount) * invoice_items.quantity)) END + CASE tax_types.tax IS NULL WHEN TRUE THEN 0 ELSE (tax_types.tax / 100) * ((invoice_items.price - invoice_items.discount) * invoice_items.quantity) END total_")
    .order('invoice_items.invoice_id, invoice_items.id')
  }
  scope :by_invoice_id, -> i {
    joins(:tax_type)
    .where("invoice_items.invoice_id = #{i}")
    .select("invoice_items.invoice_id invoice_id_, invoice_items.id invoice_item_id_,
             invoice_items.code code_, invoice_items.subcode subcode_, invoice_items.description description_,
             invoice_items.quantity quantity_, invoice_items.price price_,
             tax_types.tax tax_type_tax_, invoice_items.discount discount_, invoice_items.discount_pct discount_pct_,
             (invoice_items.price - invoice_items.discount) net_price_,
             ((invoice_items.price - invoice_items.discount) * invoice_items.quantity) amount_,
             CASE invoice_items.discount_pct IS NULL WHEN TRUE THEN 0 ELSE ((invoice_items.discount_pct / 100) * ((invoice_items.price - invoice_items.discount) * invoice_items.quantity)) END bonus_,
             ((invoice_items.price - invoice_items.discount) * invoice_items.quantity) - CASE invoice_items.discount_pct IS NULL WHEN TRUE THEN 0 ELSE ((invoice_items.discount_pct / 100) * ((invoice_items.price - invoice_items.discount) * invoice_items.quantity)) END net_,
             CASE tax_types.tax IS NULL WHEN TRUE THEN 0 ELSE (tax_types.tax / 100) * ((invoice_items.price - invoice_items.discount) * invoice_items.quantity) END tax_,
             ((invoice_items.price - invoice_items.discount) * invoice_items.quantity) - CASE invoice_items.discount_pct IS NULL WHEN TRUE THEN 0 ELSE ((invoice_items.discount_pct / 100) * ((invoice_items.price - invoice_items.discount) * invoice_items.quantity)) END + CASE tax_types.tax IS NULL WHEN TRUE THEN 0 ELSE (tax_types.tax / 100) * ((invoice_items.price - invoice_items.discount) * invoice_items.quantity) END total_")
    .order('invoice_items.id')
  }

  # Callbacks
  before_validation :item_repeat, :on => :create

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

  def discount_present?
    !discount.blank? && discount != 0
  end

  def is_block?
    @@block_codes.include? subcode
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

  # Methods
  def tariff_starting_at
    formatted_date(tariff.starting_at) rescue ''
  end

  def tariff_ending_at
    formatted_date(tariff.ending_at) rescue ''
  end

  def regulation
    tariff.billable_item.regulation_id
  end

  #
  # Class (self) user defined methods
  #
  def self.subcode_names(subcode)
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

  private

  def item_repeat
    @errors.add(:base, "Item repeat") if !InvoiceItem.where(invoice_id: invoice_id, tariff_id: tariff_id, code: code, subcode: subcode).blank?
  end
end
