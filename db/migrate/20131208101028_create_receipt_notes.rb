class CreateReceiptNotes < ActiveRecord::Migration
  def change
    create_table :receipt_notes do |t|
      t.string :receipt_no
      t.references :purchase_order
      t.references :supplier
      t.references :payment_method
      t.date :receipt_date
      t.string :remarks
      t.decimal :discount_pct, :precision => 6, :scale => 2, :null => false, :default => '0'
      t.decimal :discount, :precision => 12, :scale => 4, :null => false, :default => '0'
      t.references :project
      t.references :store
      t.references :work_order
      t.references :charge_account
      t.decimal :retention_pct, :precision => 6, :scale => 2, :null => false, :default => '0'
      t.integer :retention_time

      t.timestamps
    end
    add_index :receipt_notes, :purchase_order_id
    add_index :receipt_notes, :supplier_id
    add_index :receipt_notes, :payment_method_id
    add_index :receipt_notes, :project_id
    add_index :receipt_notes, :store_id
    add_index :receipt_notes, :work_order_id
    add_index :receipt_notes, :charge_account_id
    add_index :receipt_notes, :receipt_no
    add_index :receipt_notes, :receipt_date
  end
end
