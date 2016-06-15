class RemoveManufacturerFromMeterModels < ActiveRecord::Migration
  def change
    remove_index :meter_models, :manufacturer_id
    remove_index :meter_models, :brand

    remove_column :meter_models, :manufacturer_id
    remove_column :meter_models, :brand

    add_column :meter_models, :meter_brand_id, :integer

    add_index :meter_models, :meter_brand_id
  end
end
