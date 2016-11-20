class MeterOwner < ActiveRecord::Base
  attr_accessible :name

  has_many :meters

  has_paper_trail

  validates :name,  :presence => true

  before_destroy :check_for_dependent_records

  private

  def check_for_dependent_records
    # Check for meters
    if meters.count > 0
      errors.add(:base, I18n.t('activerecord.models.meter_owner.check_for_meters'))
      return false
    end
  end
end
