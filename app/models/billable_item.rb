class BillableItem < ActiveRecord::Base
  belongs_to :project
  belongs_to :billable_concept
  belongs_to :biller, class_name: "Company", foreign_key: "biller_id"
  belongs_to :regulation

  has_many :tariffs
  has_many :tariff_types, through: :tariffs
  has_many :uses, through: :tariff_types

  has_paper_trail

  attr_accessible :biller_id, :project_id, :billable_concept_id, :regulation_id, :organization_id,
                  :tariffs_by_caliber, :bill_by_endowments, :bill_by_inhabitants, :bill_by_users

  validates :project,             :presence => true
  validates :billable_concept,    :presence => true
  validates :biller,              :presence => true
  validates :regulation,          :presence => true
  validates :billable_concept_id, :uniqueness => { :scope => [:project_id, :biller_id, :regulation_id] }
  validates :regulation_id,       :uniqueness => { :scope => [:project_id, :biller_id, :billable_concept_id] }

  # Scopes
  scope :by_code_id, -> { includes(:billable_concept).order('billable_concepts.code, billable_items.id') }
  #
  scope :belongs_to_project, -> p { where(project_id: p).by_code_id }
  scope :availables, -> { includes(:regulation).where("regulations.ending_at IS NULL OR ending_at >= ?", Date.today)}
  scope :with_tariff, -> p, bc { joins(:tariffs, :billable_concept, :regulation, :project, :biller)
                            .where("(regulations.ending_at >= ? OR regulations.ending_at IS NULL) AND (tariffs.ending_at >= ? OR tariffs.ending_at IS NULL) AND billable_concepts.billable_document = 1 AND billable_items.project_id = ? AND billable_concepts.id NOT IN (?)", Date.today, Date.today, p, bc)
                            .order("billable_concepts.id")
                            .group("billable_items.id")}

  before_save :check_sum
  before_destroy :check_for_dependent_records

  def to_label
    "#{billable_concept.name} (#{billable_concept.code}) - #{biller.name}"
  end

  def to_label_date
    "#{billable_concept.name} (#{billable_concept.code}) - #{biller.name} - #{regulation.to_date}"
  end

  def to_label_biller
    if project.company == biller
      "#{billable_concept.name} (#{billable_concept.code})"
    else
      "#{billable_concept.name} (#{billable_concept.code}) - #{biller.name}"
    end
  end

  def office
    project.office
  end

  def company
    project.company
  end

  def grouped_tariff_types
    tariff_types.group(:tariff_type_id)
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
