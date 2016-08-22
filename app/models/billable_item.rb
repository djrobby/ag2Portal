class BillableItem < ActiveRecord::Base
  belongs_to :project
  belongs_to :billable_concept
  belongs_to :biller, class_name: "Company", foreign_key: "biller_id"
  belongs_to :regulation
  attr_accessible :biller_id, :project_id, :billable_concept_id, :regulation_id

  validates :project,           :presence => true
  validates :billable_concept,  :presence => true,
                                :uniqueness => { :scope => :project_id }
  validates :biller,            :presence => true

  def to_label
    #"#{billable_concept.name} ( #{billable_concept.code} ) - #{biller.name}"
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
end
