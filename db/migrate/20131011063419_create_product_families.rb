class CreateProductFamilies < ActiveRecord::Migration
  def change
    create_table :product_families do |t|
      t.string :name
      t.string :family_code
      t.integer :max_orders_count
      t.decimal :max_orders_sum, :precision => 12, :scale => 4, :null => false, :default => '0'

      t.timestamps
    end
    add_index :product_families, :name
    add_index :product_families, :family_code
  end
end
