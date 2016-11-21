class ComplaintClass < ActiveRecord::Base
  attr_accessible :name

  has_many :complaints

  has_paper_trail

  validates :name,  :presence => true

  before_destroy :check_for_dependent_records

  private

  def check_for_dependent_records
    # Check for complaints
    if complaints.count > 0
      errors.add(:base, I18n.t('activerecord.models.complaint_class.check_for_complaints'))
      return false
    end
  end
end
