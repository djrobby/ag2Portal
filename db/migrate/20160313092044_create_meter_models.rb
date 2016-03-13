class CreateMeterModels < ActiveRecord::Migration
  def change
    create_table :meter_models do |t|
      t.references :manufacturer
      t.string :model
      t.string :brand
      t.references :meter_type

      t.timestamps
    end
    add_index :meter_models, :manufacturer_id
    add_index :meter_models, :meter_type_id
    add_index :meter_models, :model
    add_index :meter_models, :brand
  end
end
