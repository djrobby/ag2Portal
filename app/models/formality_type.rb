class FormalityType < ActiveRecord::Base
  attr_accessible :name

  has_many :formalities

  has_paper_trail

  validates :name,          :presence => true

  before_destroy :check_for_dependent_records

  private

  def check_for_dependent_records
    # Check for formalities
    if formalities.count > 0
      errors.add(:base, I18n.t('activerecord.models.formality_type.check_for_formalities'))
      return false
    end
  end
end
