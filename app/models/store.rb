class Store < ActiveRecord::Base
  belongs_to :company
  belongs_to :office
  belongs_to :organization
  belongs_to :supplier
  belongs_to :province
  belongs_to :town
  belongs_to :zipcode
  belongs_to :street_type
  attr_accessible :location, :name, :company_id, :office_id,
                  :organization_id, :supplier_id,
                  :street_type_id, :street_name, :street_number, :building, :floor, :floor_office,
                  :zipcode_id, :town_id, :province_id, :phone, :fax, :email

  has_many :stocks
  has_many :products, :through => :stocks
  has_many :work_orders
  has_many :work_order_items
  has_many :receipt_notes
  has_many :receipt_note_items
  has_many :delivery_notes
  has_many :delivery_note_items
  has_many :purchase_orders
  has_many :purchase_order_items
  has_many :offer_requests
  has_many :offer_request_items
  has_many :offers
  has_many :offers_items
  has_many :sale_offers
  has_many :sale_offer_items

  has_paper_trail

  validates :name,          :presence => true
  validates :company,       :presence => true, :if => "supplier.blank?"
  validates :supplier,      :presence => true, :if => "company.blank?"
  validates :street_type,   :presence => true
  validates :zipcode,       :presence => true
  validates :town,          :presence => true
  validates :province,      :presence => true

  before_destroy :check_for_dependent_records

  #
  # Calculated fields
  #
  def stock
    stocks.sum("current")
  end

  def receipts
    receipt_note_items.sum("quantity")
  end

  def deliveries
    delivery_note_items.sum("quantity")
  end

  def address_1
    _ret = ""
    if !street_type.blank?
      _ret += street_type.street_type_code.titleize + ". "
    end
    if !street_name.blank?
      _ret += street_name + " "
    end
    if !street_number.blank?
      _ret += street_number + ", "
    end
    if !building.blank?
      _ret += building.titleize + ", "
    end
    if !floor.blank?
      _ret += floor_human + " "
    end
    if !floor_office.blank?
      _ret += floor_office
    end
    _ret
  end

  def address_2
    _ret = ""
    if !zipcode.blank?
      _ret += zipcode.zipcode + " "
    end
    if !town.blank?
      _ret += town.name + ", "
    end
    if !province.blank?
      _ret += province.name + " "
      if !province.region.country.blank?
        _ret += "(" + province.region.country.name + ")"
      end
    end
    _ret
  end

  def floor_human
    _ret = floor
    _floor_is_numeric = true if Float(floor) rescue false
    if _floor_is_numeric
      _ret = floor.strip + "\xBA".force_encoding('ISO-8859-1').encode('UTF-8')
    end
    _ret
  end

  def phone_and_fax
    _ret = ""
    if !self.phone.blank?
      _ret += I18n.t("activerecord.attributes.store.phone_c") + ": " + self.phone.strip
    end
    if !self.fax.blank?
      _ret += _ret.blank? ? I18n.t("activerecord.attributes.store.fax") + ": " + self.fax.strip : " / " + I18n.t("activerecord.attributes.store.fax") + ": " + self.fax.strip
    end
    _ret
  end

  private

  def check_for_dependent_records
    # Check for stocks
    if stocks.count > 0
      errors.add(:base, I18n.t('activerecord.models.store.check_for_stocks'))
      return false
    end
    # Check for work orders
    if work_orders.count > 0
      errors.add(:base, I18n.t('activerecord.models.store.check_for_work_orders'))
      return false
    end
    # Check for work order items
    if work_order_items.count > 0
      errors.add(:base, I18n.t('activerecord.models.store.check_for_work_orders'))
      return false
    end
    # Check for receipt notes
    if receipt_notes.count > 0
      errors.add(:base, I18n.t('activerecord.models.store.check_for_receipt_notes'))
      return false
    end
    # Check for receipt note items
    if receipt_note_items.count > 0
      errors.add(:base, I18n.t('activerecord.models.store.check_for_receipt_notes'))
      return false
    end
    # Check for delivery notes
    if delivery_notes.count > 0
      errors.add(:base, I18n.t('activerecord.models.store.check_for_delivery_notes'))
      return false
    end
    # Check for delivery note items
    if delivery_note_items.count > 0
      errors.add(:base, I18n.t('activerecord.models.store.check_for_delivery_notes'))
      return false
    end
    # Check for purchase orders
    if purchase_orders.count > 0
      errors.add(:base, I18n.t('activerecord.models.store.check_for_purchase_orders'))
      return false
    end
    # Check for purchase order items
    if purchase_order_items.count > 0
      errors.add(:base, I18n.t('activerecord.models.store.check_for_purchase_orders'))
      return false
    end
    # Check for offer requests
    if offer_requests.count > 0
      errors.add(:base, I18n.t('activerecord.models.store.check_for_offer_requests'))
      return false
    end
    # Check for offer request items
    if offer_request_items.count > 0
      errors.add(:base, I18n.t('activerecord.models.store.check_for_offer_requests'))
      return false
    end
    # Check for offers
    if offers.count > 0
      errors.add(:base, I18n.t('activerecord.models.store.check_for_offers'))
      return false
    end
    # Check for offer items
    if offer_items.count > 0
      errors.add(:base, I18n.t('activerecord.models.store.check_for_offers'))
      return false
    end
    # Check for sale offers
    if sale_offers.count > 0
      errors.add(:base, I18n.t('activerecord.models.store.check_for_sale_offers'))
      return false
    end
    # Check for sale offer items
    if sale_offer_items.count > 0
      errors.add(:base, I18n.t('activerecord.models.store.check_for_sale_offers'))
      return false
    end
  end
end
