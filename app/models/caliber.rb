class Caliber < ActiveRecord::Base
  attr_accessible :caliber, :letter_id, :nominal_flow

  has_many :meters

  has_paper_trail

  validates :caliber,     :presence => true,
                          :numericality => true
  validates :letter_id,   :length => { :is => 1 }

  # Scopes
  scope :by_caliber, -> { order(:caliber) }

  before_destroy :check_for_dependent_records

  def to_label
    caliber
  end

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
