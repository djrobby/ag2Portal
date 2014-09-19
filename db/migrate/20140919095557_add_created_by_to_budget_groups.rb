class AddCreatedByToBudgetGroups < ActiveRecord::Migration
  def change
    add_column :budget_groups, :created_by, :integer
    add_column :budget_groups, :updated_by, :integer
  end
end
