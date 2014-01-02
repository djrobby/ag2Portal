class TimerecordType < ActiveRecord::Base
  attr_accessible :name,
                  :created_by, :updated_by

  has_many :time_records

  has_paper_trail

  validates :name,  :presence => true,
                    :length => { :is => 1},
                    :uniqueness => true

  before_validation :fields_to_uppercase
  before_destroy :check_for_records

  def fields_to_uppercase
    if !self.name.blank?
      self[:name].upcase!
    end
  end

  private

  def check_for_records
    # Check for time records
    if time_records.count > 0
      errors.add(:base, I18n.t('activerecord.models.timerecord_type.check_for_records'))
      return false
    end
  end
end
