class ReadingType < ActiveRecord::Base
  # CONSTANTS (bad, change to right!)
  # NORMAL = 1
  # OCTAVILLA = 2
  # CONTROL = 3
  # INSTALACION = 4
  # RETIRADA = 5
  # AUTO = 6

  # CONSTANTS (right)
  INSTALACION = 1
  NORMAL = 2
  AUTO = 3
  OCTAVILLA = 4
  CONTROL = 5
  RETIRADA = 6

  attr_accessible :name

  has_many :pre_readings
  has_many :readings

  has_paper_trail

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
