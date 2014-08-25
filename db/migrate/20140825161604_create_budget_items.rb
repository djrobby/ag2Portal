class CreateBudgetItems < ActiveRecord::Migration
  def change
    create_table :budget_items do |t|
      t.references :budget
      t.references :charge_account
      t.decimal :amount, :precision => 13, :scale => 4, :null => false, :default => '0'
      t.decimal :corrected_amount, :precision => 13, :scale => 4, :null => false, :default => '0'

      t.timestamps
    end
    add_index :budget_items, :budget_id
    add_index :budget_items, :charge_account_id
  end
end
