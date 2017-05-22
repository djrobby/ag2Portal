class CreateCashDeskClosingItems < ActiveRecord::Migration
  def change
    create_table :cash_desk_closing_items do |t|
      t.references :cash_desk_closing
      t.references :client_payment
      t.references :supplier_payment
      t.string :type, :limit => 1, :null => false
      t.decimal :amount, :precision => 13, :scale => 4, :null => false, :default => 0

      t.timestamps
    end
    add_index :cash_desk_closing_items, :cash_desk_closing_id
    add_index :cash_desk_closing_items, :client_payment_id
    add_index :cash_desk_closing_items, :supplier_payment_id
  end
end
