class Budget < ActiveRecord::Base
  belongs_to :project
  belongs_to :organization
  belongs_to :budget_period
  belongs_to :approver, class_name: 'User'
  attr_accessible :budget_no, :description, :project_id, :organization_id,
                  :budget_period_id, :approver_id, :approval_date
  
  has_many :budget_items, dependent: :destroy

  # Nested attributes
  accepts_nested_attributes_for :budget_items,                                 
                                :reject_if => :all_blank,
                                :allow_destroy => true

  has_paper_trail

  validates_associated :budget_items
end
