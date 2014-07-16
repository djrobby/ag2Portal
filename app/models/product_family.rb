class ProductFamily < ActiveRecord::Base
  attr_accessible :family_code, :max_orders_count, :max_orders_sum, :name

  has_paper_trail

  validates :name,        :presence => true
  validates :family_code, :presence => true,
                          :length => { :is => 4 },
                          :uniqueness => true

  has_many :products

  before_validation :fields_to_uppercase

  before_destroy :check_for_dependent_records
  def fields_to_uppercase
    if !self.family_code.blank?
      self[:family_code].upcase!
    end
  end

  def to_label
    "#{name} (#{family_code})"
  end

  private

  def check_for_dependent_records
    # Check for products
    if products.count > 0
      errors.add(:base, I18n.t('activerecord.models.product_family.check_for_products'))
      return false
    end
  end
end
