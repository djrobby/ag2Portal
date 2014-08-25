class AddCreatedByToBudgets < ActiveRecord::Migration
  def change
    add_column :budgets, :created_by, :integer
    add_column :budgets, :updated_by, :integer
  end
end
