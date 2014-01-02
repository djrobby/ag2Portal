class DegreeType < ActiveRecord::Base
  attr_accessible :dt_code, :name,
                  :created_by, :updated_by, :nomina_id

  has_many :workers

  has_paper_trail

  validates :dt_code, :presence => true,
                      :length => { :minimum => 2 },
                      :uniqueness => true
  validates :name,    :presence => true
  
  before_validation :fields_to_uppercase
  before_destroy :check_for_dependent_records

  def fields_to_uppercase
    if !self.dt_code.blank?
      self[:dt_code].upcase!
    end
  end

  def to_label
    "#{name} (#{dt_code})"
  end

  private

  def check_for_dependent_records
    # Check for worker items
    if workers.count > 0
      errors.add(:base, I18n.t('activerecord.models.degree_type.check_for_workers'))
      return false
    end
  end
end
