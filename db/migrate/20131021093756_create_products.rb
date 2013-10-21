class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :product_code
      t.string :main_description
      t.string :aux_description
      t.references :product_type
      t.references :product_family
      t.references :measure
      t.references :tax_type
      t.references :manufacturer
      t.string :manufacturer_p_code
      t.decimal :reference_price
      t.decimal :last_price
      t.decimal :average_price
      t.decimal :sell_price
      t.decimal :markup
      t.integer :warranty_time
      t.integer :life_time
      t.boolean :active
      t.string :aux_code
      t.string :remarks

      t.timestamps
    end
    add_index :products, :product_type_id
    add_index :products, :product_family_id
    add_index :products, :measure_id
    add_index :products, :tax_type_id
    add_index :products, :manufacturer_id
  end
end
