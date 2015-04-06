class AddCreatedByToBudgetRatios < ActiveRecord::Migration
  def change
    add_column :budget_ratios, :created_by, :integer
    add_column :budget_ratios, :updated_by, :integer
  end
end
