class Product < ActiveRecord::Base
  belongs_to :product_type
  belongs_to :product_family
  belongs_to :measure
  belongs_to :tax_type
  belongs_to :manufacturer
  belongs_to :organization
  attr_accessible :active, :aux_code, :aux_description, :average_price, :last_price, :life_time,
                  :main_description, :manufacturer_p_code, :markup, :product_code, :reference_price,
                  :remarks, :sell_price, :warranty_time, :prev_last_price,
                  :product_type_id, :product_family_id, :measure_id, :tax_type_id,
                  :manufacturer_id, :organization_id
  has_attached_file :image, :styles => { :original => "160x160>", :medium => "120x120>", :small => "80x80>" }, :default_url => "/images/missing/:style/product.png"

  has_many :purchase_prices, dependent: :destroy
  has_many :suppliers, :through => :purchase_prices
  has_many :stocks
  has_many :stores, :through => :stocks
  has_many :work_order_items
  has_many :receipt_note_items
  has_many :delivery_note_items
  has_many :purchase_order_items
  has_many :offer_request_items
  has_many :offer_items
  has_many :supplier_invoice_items
  has_many :sale_offer_items

  has_paper_trail

  validates :main_description,  :presence => true
  validates :product_code,      :presence => true,
                                :length => { :is => 10 },
                                :format => { with: /\A\d+\Z/, message: :code_invalid },
                                :uniqueness => { :scope => :organization_id }
  validates :product_type,      :presence => true
  validates :product_family,    :presence => true
  validates :measure,           :presence => true
  validates :tax_type,          :presence => true
  validates :manufacturer,      :presence => true
  validates :organization,      :presence => true

  validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/

  before_validation :fields_to_uppercase
  before_destroy :check_for_dependent_records
  before_save :update_sell_price

  def fields_to_uppercase
    if !self.product_code.blank?
      self[:product_code].upcase!
    end
    if !self.main_description.blank?
      self[:main_description].upcase!
    end
    if !self.aux_description.blank?
      self[:aux_description].upcase!
    end
    true
  end

  def to_label
    "#{full_name}"
  end

  def full_name
    full_name = full_code
    if !self.main_description.blank?
      full_name += " " + self.main_description[0,40]
    end
    full_name
  end

  def full_code
    # Product code (Family code & sequential number) => FFFF-NNNNNN
    product_code.blank? ? "" : product_code[0..3] + '-' + product_code[4..9]
  end
  
  #
  # Calculated fields
  #
  def active_yes_no
    active ? 'Yes' : 'No'
  end

  def stock
    stocks.sum("current")
  end
  
  #
  # Records navigator
  #
  def to_first
    Product.order("product_code, id").first
  end

  def to_prev
    Product.where("product_code < ?", product_code).order("product_code, id").last
  end

  def to_next
    Product.where("product_code > ?", product_code).order("product_code, id").first
  end

  def to_last
    Product.order("product_code, id").last
  end

  def duplicate
    Product.where("product_code = ?", product_code).count
  end

  def to_duplicate_prev
    Product.where("product_code = ? and id < ?", product_code, id).order("product_code, id").last
  end

  def to_duplicate_next
    Product.where("product_code = ? and id > ?", product_code, id).order("product_code, id").first
  end

  searchable do
    text :product_code, :main_description, :aux_description, :manufacturer_p_code
    string :product_code
    string :main_description
    integer :product_type_id
    integer :product_family_id
    integer :measure_id
    integer :manufacturer_id
    integer :tax_type_id
    integer :organization_id
  end

  private

  # Before destroy
  def check_for_dependent_records
    # Check for stocks
    if stocks.count > 0
      errors.add(:base, I18n.t('activerecord.models.product.check_for_stocks'))
      return false
    end
    # Check for work order items
    if work_order_items.count > 0
      errors.add(:base, I18n.t('activerecord.models.product.check_for_work_orders'))
      return false
    end
    # Check for purchase order items
    if purchase_order_items.count > 0
      errors.add(:base, I18n.t('activerecord.models.product.check_for_purchase_orders'))
      return false
    end
    # Check for receipt note items
    if receipt_note_items.count > 0
      errors.add(:base, I18n.t('activerecord.models.product.check_for_receipt_notes'))
      return false
    end
    # Check for offer request items
    if offer_request_items.count > 0
      errors.add(:base, I18n.t('activerecord.models.product.check_for_offer_requests'))
      return false
    end
    # Check for offer items
    if offer_items.count > 0
      errors.add(:base, I18n.t('activerecord.models.product.check_for_offers'))
      return false
    end
    # Check for delivery note items
    if delivery_note_items.count > 0
      errors.add(:base, I18n.t('activerecord.models.product.check_for_delivery_notes'))
      return false
    end
    # Check for supplier invoice items
    if supplier_invoice_items.count > 0
      errors.add(:base, I18n.t('activerecord.models.product.check_for_supplier_invoices'))
      return false
    end
    # Check for client invoice items
    if supplier_invoice_items.count > 0
      errors.add(:base, I18n.t('activerecord.models.product.check_for_client_invoices'))
      return false
    end
    # Check for sale offer items
    if sale_offer_items.count > 0
      errors.add(:base, I18n.t('activerecord.models.product.check_for_sale_offers'))
      return false
    end
  end
  
  # Before save
  def update_sell_price
    if !reference_price.blank? && !markup.blank?
      self.sell_price = reference_price * (1 + (markup / 100))
    end
    true
  end
end
