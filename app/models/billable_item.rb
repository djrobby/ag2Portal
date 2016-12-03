class BillableItem < ActiveRecord::Base
  belongs_to :project
  belongs_to :billable_concept
  belongs_to :biller, class_name: "Company", foreign_key: "biller_id"
  belongs_to :regulation

  has_many :tariffs

  has_paper_trail

  attr_accessible :biller_id, :project_id, :billable_concept_id, :tariffs_by_caliber, :regulation_id, :organization_id

  validates :project,           :presence => true
  validates :billable_concept,  :presence => true
  validates :biller,            :presence => true
  validates :billable_concept_id, uniqueness: { scope: :project_id }

  before_save :check_sum
  before_destroy :check_for_dependent_records

  def to_label
    "#{billable_concept.name} (#{billable_concept.code}) - #{biller.name}"
  end

  def office
    project.office
  end

  def company
    project.company
  end

  searchable do
    integer :project_id
    integer :billable_concept_id
    integer :biller_id
    integer :regulation_id
  end

  private

  def check_sum
     self.tariffs_by_caliber = true if billable_concept.try(:code) == "SUM"
  end

  def check_for_dependent_records
    # Check for tariffs
    if tariffs.count > 0
      errors.add(:base, I18n.t('activerecord.models.billable_item.check_for_tariffs'))
      return false
    end
  end
end
