class Department < ActiveRecord::Base
  attr_accessible :name, :code,
                  :created_by, :updated_by

  has_many :areas
  has_many :workers
  has_many :worker_items
  has_many :corp_contacts

  has_paper_trail

  validates :name,  :presence => true
  validates :code,  :presence => true,
                    :length => { :in => 2..5 }

  before_validation :fields_to_uppercase
  before_destroy :check_for_dependent_records

  def fields_to_uppercase
    if !self.code.blank?
      self[:code].upcase!
    end
  end

  def to_label
    "#{name} (#{code})"
  end
  
  private
  
  def check_for_dependent_records
    # Check for workers
    if workers.count > 0
      errors.add(:base, I18n.t('activerecord.models.department.check_for_workers'))
      return false
    end
    # Check for areas
    if areas.count > 0
      errors.add(:base, I18n.t('activerecord.models.department.check_for_areas'))
      return false
    end
  end
end
