class SalaryConcept < ActiveRecord::Base
  attr_accessible :name, :nomina_id

  has_many :worker_salary_items

  has_paper_trail

  validates :name,  :presence => true

  before_destroy :check_for_dependent_records

  private

  def check_for_dependent_records
    # Check for salary items
    if worker_salary_items.count > 0
      errors.add(:base, I18n.t('activerecord.models.salary_concept.check_for_salary_items'))
      return false
    end
  end
end
