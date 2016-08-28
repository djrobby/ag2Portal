class CreateInstalments < ActiveRecord::Migration
  def change
    create_table :instalments do |t|
      t.references :instalment_plan
      t.references :bill
      t.references :invoice
      t.integer :instalment
      t.date :payday_limit
      t.decimal :amount, :precision => 12, :scale => 4, :null => false, :default => '0'
      t.decimal :surcharge, :precision => 12, :scale => 4, :null => false, :default => '0'

      t.timestamps
    end
    add_index :instalments, :instalment_plan_id
    add_index :instalments, :bill_id
    add_index :instalments, :invoice_id
    add_index :instalments, :payday_limit
  end
end
