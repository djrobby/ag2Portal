class AddCreatedByToBudgetPeriods < ActiveRecord::Migration
  def change
    add_column :budget_periods, :created_by, :integer
    add_column :budget_periods, :updated_by, :integer
  end
end
