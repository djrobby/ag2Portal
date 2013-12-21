class CreateDeliveryNotes < ActiveRecord::Migration
  def change
    create_table :delivery_notes do |t|
      t.string :delivery_no
      t.references :client
      t.references :payment_method
      t.date :delivery_date
      t.string :remarks
      t.decimal :discount_pct, :precision => 6, :scale => 2, :null => false, :default => '0'
      t.decimal :discount, :precision => 12, :scale => 4, :null => false, :default => '0'
      t.references :project
      t.references :store
      t.references :work_order
      t.references :charge_account

      t.timestamps
    end
    add_index :delivery_notes, :client_id
    add_index :delivery_notes, :payment_method_id
    add_index :delivery_notes, :project_id
    add_index :delivery_notes, :store_id
    add_index :delivery_notes, :work_order_id
    add_index :delivery_notes, :charge_account_id
    add_index :delivery_notes, :delivery_no
    add_index :delivery_notes, :delivery_date
  end
end
