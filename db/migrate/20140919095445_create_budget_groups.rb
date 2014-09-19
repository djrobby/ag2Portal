class CreateBudgetGroups < ActiveRecord::Migration
  def change
    create_table :budget_groups do |t|
      t.references :budget
      t.references :charge_group

      t.timestamps
    end
    add_index :budget_groups, :budget_id
    add_index :budget_groups, :charge_group_id
  end
end
