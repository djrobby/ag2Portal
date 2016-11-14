class ReadingIncidenceType < ActiveRecord::Base
  attr_accessible :name, :should_estimate, :is_main, :code

  has_many :reading_incidences
  has_many :pre_reading_incidences

  validates :name,  :presence => true
  validates :code,  :presence => true,
                    :length => { :minimum => 1, :maximum => 2 },
                    :format => { with: /\A[a-zA-Z\d]+\Z/, message: :code_invalid },
                    :uniqueness => true

  before_destroy :check_for_dependent_records

  def to_label
    "#{name}"
  end

  private

  def check_for_dependent_records
    # Check for reading incidences
    if reading_incidences.count > 0
      errors.add(:base, I18n.t('activerecord.models.formality_type.check_for_reading_incidences'))
      return false
    end
    # Check for pre-reading incidences
    if pre_reading_incidences.count > 0
      errors.add(:base, I18n.t('activerecord.models.formality_type.check_for_pre_reading_incidences'))
      return false
    end
  end
end
