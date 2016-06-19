class MeterModel < ActiveRecord::Base
  belongs_to :meter_type
  belongs_to :meter_brand
  attr_accessible :model, :meter_type_id, :meter_brand_id, :digits, :dials

  has_many :meters

  has_paper_trail

  validates :meter_type,    :presence => true
  validates :meter_brand,   :presence => true
  validates :model,         :presence => true
  validates :digits,        :presence => true

  before_validation :fields_to_uppercase
  before_destroy :check_for_dependent_records

  def fields_to_uppercase
    if !self.model.blank?
      self[:model].upcase!
    end
  end

  def to_label
    "#{full_name}"
  end

  def full_name
    full_name = ""
    if !self.model.blank?
      full_name += self.model
    end
    if !self.meter_brand.blank?
      full_name += " (" + self.meter_brand.brand + ")"
    end
    full_name
  end

  private

  # Before destroy
  def check_for_dependent_records
    # Check for meters
    if meters.count > 0
      errors.add(:base, I18n.t('activerecord.models.meter_model.check_for_meters'))
      return false
    end
  end
end
