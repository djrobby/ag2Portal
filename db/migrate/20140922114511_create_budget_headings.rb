class CreateBudgetHeadings < ActiveRecord::Migration
  def change
    create_table :budget_headings do |t|
      t.string :heading_code
      t.string :name
      t.references :organization

      t.timestamps
    end
    add_index :budget_headings, :organization_id
    add_index :budget_headings, :heading_code
    add_index :budget_headings, [:organization_id, :heading_code], unique: true, name: 'index_budget_headings_on_organization_and_code'
  end
end
