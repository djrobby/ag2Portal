class Product < ActiveRecord::Base
  belongs_to :product_type
  belongs_to :product_family
  belongs_to :measure
  belongs_to :tax_type
  belongs_to :manufacturer
  attr_accessible :active, :aux_code, :aux_description, :average_price, :last_price, :life_time,
                  :main_description, :manufacturer_p_code, :markup, :product_code, :reference_price,
                  :remarks, :sell_price, :warranty_time,
                  :product_type_id, :product_family_id, :measure_id, :tax_type_id, :manufacturer_id
  has_attached_file :image, :styles => { :medium => "120x120>", :small => "80x80>" }, :default_url => "/images/missing/:style/product.png"

  has_paper_trail

  validates :main_description,  :presence => true
  validates :product_code,      :presence => true,
                                :length => { :in => 4..11 },
                                :uniqueness => true
  validates :product_type_id,   :presence => true
  validates :product_family_id, :presence => true
  validates :measure_id,        :presence => true
  validates :tax_type_id,       :presence => true
  validates :manufacturer_id,   :presence => true

  before_validation :fields_to_uppercase

  before_destroy :check_for_dependent_records

  has_many :purchase_prices, dependent: :destroy
  has_many :suppliers, :through => :purchase_prices
  has_many :stocks
  has_many :stores, :through => :stocks

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
  end

  def to_label
    "#{product_code} #{main_description}"
  end

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
    Product.order("product_code").first
  end

  def to_prev
    Product.where("product_code < ?", product_code).order("product_code").last
  end

  def to_next
    Product.where("product_code > ?", product_code).order("product_code").first
  end

  def to_last
    Product.order("product_code").last
  end

  private

  def check_for_dependent_records
    # Check for stocks
    if stocks.count > 0
      errors.add(:base, I18n.t('activerecord.models.store.check_for_stocks'))
      return false
    end
    # Check for orders & ...
#    if orders.count > 0
#      errors.add(:base, I18n.t('activerecord.models.product.check_for_orders'))
#      return false
#    end
  end

  searchable do
    text :product_code, :main_description, :aux_description, :manufacturer_p_code
    integer :product_type_id
    integer :product_family_id
    integer :measure_id
    integer :manufacturer_id
    integer :tax_type_id
    string :product_code
  end
end
