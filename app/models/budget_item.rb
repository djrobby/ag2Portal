class BudgetItem < ActiveRecord::Base
  belongs_to :budget
  belongs_to :charge_account
  attr_accessible :amount, :corrected_amount, :budget_id, :charge_account_id

  has_paper_trail
end
