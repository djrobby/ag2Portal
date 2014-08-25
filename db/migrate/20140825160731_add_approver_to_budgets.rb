class AddApproverToBudgets < ActiveRecord::Migration
  def change
    add_column :budgets, :approver_id, :integer
    add_column :budgets, :approval_date, :timestamp
    add_index :budgets, :approver_id
  end
end
