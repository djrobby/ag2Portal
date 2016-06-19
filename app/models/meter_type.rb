class MeterType < ActiveRecord::Base
  attr_accessible :name

  has_many :meter_models

  has_paper_trail

  validates :name,  :presence => true

  before_destroy :check_for_dependent_records

  private

  # Before destroy
  def check_for_dependent_records
    # Check for meter_models
    if meter_models.count > 0
      errors.add(:base, I18n.t('activerecord.models.meter_type.check_for_meter_models'))
      return false
    end
  endend
