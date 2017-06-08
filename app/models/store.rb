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
  attr_accessible :store_offices_attributes

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
  has_many :inventory_counts
  has_many :inventory_count_items, :through => :inventory_counts
  has_many :store_offices, dependent: :destroy
  has_many :product_valued_stocks
  has_many :product_valued_stock_by_companies
  has_many :outbound_inventory_transfers, class_name: 'InventoryTransfer', foreign_key: :outbound_store_id
  has_many :outbound_inventory_transfer_items, :through => :outbound_inventory_transfers
  has_many :inbound_inventory_transfers, class_name: 'InventoryTransfer', foreign_key: :inbound_store_id
  has_many :inbound_inventory_transfer_items, :through => :inbound_inventory_transfers

  # Nested attributes
  accepts_nested_attributes_for :store_offices,
                                :reject_if => :all_blank,
                                :allow_destroy => true

  has_paper_trail

  validates_associated :store_offices

  validates :name,          :presence => true
  validates :company,       :presence => true, :if => "supplier.blank?"
  validates :supplier,      :presence => true, :if => "company.blank?"
  validates :street_type,   :presence => true
  validates :zipcode,       :presence => true
  validates :town,          :presence => true
  validates :province,      :presence => true

  # Scopes
  scope :by_name, -> { order(:name) }
  #
  scope :belongs_to_organization, -> organization { where("organization_id = ?", organization).by_name }
  scope :belongs_to_company, -> company { where("company_id = ?", company).by_name }
  scope :belongs_to_office, -> office { where("office_id = ?", office).by_name }

  before_destroy :check_for_dependent_records

  #
  # Calculated fields
  #
  def stock
    stocks.sum("current")
  end

  def initial
    stocks.sum("initial")
  end

  # Receipts
  def receipts
    receipt_note_items.sum("quantity")
  end
  def receipts_price_avg
    receipt_note_items.sum("price") / receipt_note_items.count
  end
  def receipts_discount
    receipt_note_items.sum("discount")
  end
  def receipts_amount
    _sum = 0
    receipt_note_items.each do |i|
      if !i.amount.blank?
        _sum += i.amount
      end
    end
    _sum
  end
  def receipts_tax
    _sum = 0
    receipt_note_items.each do |i|
      if !i.tax.blank?
        _sum += i.tax
      end
    end
    _sum
  end
  def receipts_price_avg_total
    cnt = receipts != 0 ? receipts : 1
    receipts_amount / cnt
  end

  # Deliveries
  def deliveries
    delivery_note_items.sum("quantity")
  end
  def deliveries_price_avg
    delivery_note_items.sum("price") / delivery_note_items.count
  end
  def deliveries_cost_avg
    delivery_note_items.sum("cost") / delivery_note_items.count
  end
  def deliveries_discount
    delivery_note_items.sum("discount")
  end
  def deliveries_amount
    _sum = 0
    delivery_note_items.each do |i|
      if !i.amount.blank?
        _sum += i.amount
      end
    end
    _sum
  end
  def deliveries_costs
    _sum = 0
    delivery_note_items.each do |i|
      if !i.costs.blank?
        _sum += i.costs
      end
    end
    _sum
  end
  def deliveries_tax
    _sum = 0
    delivery_note_items.each do |i|
      if !i.tax.blank?
        _sum += i.tax
      end
    end
    _sum
  end
  def deliveries_price_avg_total
    cnt = deliveries != 0 ? deliveries : 1
    deliveries_amount / cnt
  end
  def deliveries_cost_avg_total
    cnt = deliveries != 0 ? deliveries : 1
    deliveries_costs / cnt
  end

  # Inventory counts
  def counts
    inventory_count_items.sum("quantity")
  end
  def counts_price_avg
    inventory_count_items.sum("price") / inventory_count_items.count
  end

  # Stock rotation rate
  def rotation_rate
    deliveries / ((initial + stock) / 2)
    #deliveries_costs / average_price
  end

  # Address helpers
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
    # Check for inventory counts
    if inventory_counts.count > 0
      errors.add(:base, I18n.t('activerecord.models.store.check_for_counts'))
      return false
    end
  end
end
