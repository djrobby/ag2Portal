class CreateMeterBrands < ActiveRecord::Migration
  def change
    create_table :meter_brands do |t|
      t.references :manufacturer
      t.string :brand

      t.timestamps
    end
    add_index :meter_brands, :manufacturer_id
    add_index :meter_brands, :brand
  end
end
