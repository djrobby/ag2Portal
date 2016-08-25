class MeterBrand < ActiveRecord::Base
  belongs_to :manufacturer
  attr_accessible :brand, :manufacturer_id, :letter_id

  has_many :meter_models

  has_paper_trail

  validates :manufacturer,  :presence => true
  validates :brand,         :presence => true

  before_validation :fields_to_uppercase
  before_destroy :check_for_dependent_records

  def fields_to_uppercase
    if !self.brand.blank?
      self[:brand].upcase!
    end
  end

  def to_label
    "#{full_name}"
  end

  def full_name
    full_name = ""
    if !self.brand.blank?
      full_name += self.brand
    end
    if !self.manufacturer.blank?
      full_name += " (" + self.manufacturer.name + ")"
    end
    full_name
  end

  private

  # Before destroy
  def check_for_dependent_records
    # Check for meter brands
    if meter_models.count > 0
      errors.add(:base, I18n.t('activerecord.models.meter_brand.check_for_meter_models'))
      return false
    end
  end
end
