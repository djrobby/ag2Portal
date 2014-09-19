class BudgetGroup < ActiveRecord::Base
  belongs_to :budget
  belongs_to :charge_group
  attr_accessible :budget_id, :charge_group_id

  has_paper_trail

  validates :budget,        :presence => true
  validates :charge_group,  :presence => true
end
