class BudgetItem < ActiveRecord::Base
  belongs_to :budget
  belongs_to :charge_account
  attr_accessible :amount, :corrected_amount, :budget_id, :charge_account_id,
                  :month_01, :month_02, :month_03, :month_04, :month_05, :month_06,
                  :month_07, :month_08, :month_09, :month_10, :month_11, :month_12

  has_paper_trail
end
