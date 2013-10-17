class ProductType < ActiveRecord::Base
  attr_accessible :description

  has_paper_trail

  validates :description, :presence => true

  has_many :products

  before_destroy :check_for_dependent_records

  private
  
  def check_for_dependent_records
    # Check for products
    if products.count > 0
      errors.add(:base, I18n.t('activerecord.models.product_type.check_for_products'))
    return false
    end
  end
end
