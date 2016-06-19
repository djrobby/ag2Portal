class Manufacturer < ActiveRecord::Base
  attr_accessible :name

  has_paper_trail

  validates :name,  :presence => true

  has_many :products
  has_many :meter_brands

  before_destroy :check_for_dependent_records

  private

  # Before destroy
  def check_for_dependent_records
    # Check for products
    if products.count > 0
      errors.add(:base, I18n.t('activerecord.models.manufacturer.check_for_products'))
      return false
    end
    # Check for meter brands
    if meter_brands.count > 0
      errors.add(:base, I18n.t('activerecord.models.manufacturer.check_for_meter_brands'))
      return false
    end
  end
end
