class AddCreatedByToBudgetHeadings < ActiveRecord::Migration
  def change
    add_column :budget_headings, :created_by, :integer
    add_column :budget_headings, :updated_by, :integer
  end
end
