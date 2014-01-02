class TimerecordCode < ActiveRecord::Base
  attr_accessible :name,
                  :created_by, :updated_by

  has_many :time_records

  has_paper_trail

  validates :name,  :presence => true

  before_destroy :check_for_records

  private

  def check_for_records
    # Check for time records
    if time_records.count > 0
      errors.add(:base, I18n.t('activerecord.models.timerecord_code.check_for_records'))
      return false
    end
  end
end
