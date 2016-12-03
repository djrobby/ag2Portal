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
  before_validation :fields_to_uppercase

  def to_label
    caliber
  end

  private

  def fields_to_uppercase
    if !self.letter_id.blank?
      self[:letter_id].upcase!
    end
  end

  # Before destroy
  def check_for_dependent_records
    # Check for meters
    if meters.count > 0
      errors.add(:base, I18n.t('activerecord.models.caliber.check_for_meters'))
      return false
    end
  end
end
