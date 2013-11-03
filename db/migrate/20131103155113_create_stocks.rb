class CreateStocks < ActiveRecord::Migration
  def change
    create_table :stocks do |t|
      t.references :product
      t.references :store
      t.decimal :initial, :precision => 12, :scale => 4, :null => false, :default => '0'
      t.decimal :current, :precision => 12, :scale => 4, :null => false, :default => '0'
      t.decimal :minimum, :precision => 12, :scale => 4, :null => false, :default => '0'
      t.string :location

      t.timestamps
    end
    add_index :stocks, :product_id
    add_index :stocks, :store_id
  end
end
