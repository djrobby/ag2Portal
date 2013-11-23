class CreatePurchaseOrders < ActiveRecord::Migration
  def change
    create_table :purchase_orders do |t|
      t.string :order_no
      t.references :supplier
      t.references :payment_method
      t.references :order_status
      t.date :order_date
      t.string :remarks
      t.decimal :discount_pct, :precision => 6, :scale => 2, :null => false, :default => '0'
      t.decimal :discount, :precision => 12, :scale => 4, :null => false, :default => '0'
      t.string :supplier_offer_no

      t.timestamps
    end
    add_index :purchase_orders, :supplier_id
    add_index :purchase_orders, :payment_method_id
    add_index :purchase_orders, :order_status_id
    add_index :purchase_orders, :order_date
    add_index :purchase_orders, :order_no
  end
end
