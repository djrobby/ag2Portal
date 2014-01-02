class ProfessionalGroup < ActiveRecord::Base
  attr_accessible :name, :pg_code,
                  :created_by, :updated_by, :nomina_id

  has_many :workers
  has_many :worker_items

  has_paper_trail

  validates :pg_code, :presence => true,
                      :length => { :minimum => 2 },
                      :uniqueness => true
  validates :name,    :presence => true

  before_validation :fields_to_uppercase
  before_destroy :check_for_dependent_records
  
  def fields_to_uppercase
    if !self.pg_code.blank?
      self[:pg_code].upcase!
    end
  end

  def to_label
    "#{name} (#{pg_code})"
  end

  private

  def check_for_dependent_records
    # Check for worker items
    if worker_items.count > 0
      errors.add(:base, I18n.t('activerecord.models.professional_group.check_for_workers'))
      return false
    end
  end
end
