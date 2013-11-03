class CreatePurchasePrices < ActiveRecord::Migration
  def change
    create_table :purchase_prices do |t|
      t.references :product
      t.references :supplier
      t.string :code
      t.decimal :price, :precision => 12, :scale => 4, :null => false, :default => '0'
      t.references :measure
      t.decimal :factor, :precision => 12, :scale => 4, :null => false, :default => '0'
      t.boolean :favorite

      t.timestamps
    end
    add_index :purchase_prices, :product_id
    add_index :purchase_prices, :supplier_id
    add_index :purchase_prices, :measure_id
    add_index :purchase_prices, :code
  end
end
