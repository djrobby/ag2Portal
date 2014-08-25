class CreateBudgets < ActiveRecord::Migration
  def change
    create_table :budgets do |t|
      t.string :budget_no
      t.string :description
      t.references :project
      t.references :organization
      t.references :budget_period

      t.timestamps
    end
    add_index :budgets, :project_id
    add_index :budgets, :organization_id
    add_index :budgets, :budget_period_id
    add_index :budgets, :budget_no
    add_index :budgets, [:organization_id, :budget_no], unique: true, name: 'index_budgets_on_organization_and_code'
  end
end
