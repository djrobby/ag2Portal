class AddCreatedByToBudgetItems < ActiveRecord::Migration
  def change
    add_column :budget_items, :created_by, :integer
    add_column :budget_items, :updated_by, :integer
  end
end
