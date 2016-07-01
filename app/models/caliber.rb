class Caliber < ActiveRecord::Base
  attr_accessible :caliber

  has_many :meters

  has_paper_trail

  validates :caliber, :presence => true

  # Scopes
  scope :by_caliber, -> { order(:caliber) }

  before_destroy :check_for_dependent_records

  private

  # Before destroy
  def check_for_dependent_records
    # Check for meters
    if meters.count > 0
      errors.add(:base, I18n.t('activerecord.models.caliber.check_for_meters'))
      return false
    end
  end
end
