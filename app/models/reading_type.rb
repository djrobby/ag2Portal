class ReadingType < ActiveRecord::Base
  # CONSTANTS
  NORMAL = 1
  OCTAVILLA = 2
  CONTROL = 3
  INSTALACION = 4
  RETIRADA = 5

  attr_accessible :name

  has_many :pre_readings
  has_many :readings

  validates :name,         :presence => true

  before_destroy :check_for_dependent_records

  def to_label
    "#{name}"
  end

  private

  def check_for_dependent_records
    # Check for pre_readings
    if pre_readings.count > 0
      errors.add(:base, I18n.t('activerecord.models.reading_type.check_for_readings'))
      return false
    end
    # Check for readings
    if readings.count > 0
      errors.add(:base, I18n.t('activerecord.models.reading_type.check_for_readings'))
      return false
    end
  end
end
