class AddMasterMeterToMeters < ActiveRecord::Migration
  def change
    add_column :meters, :master_meter_id, :integer

    add_index :meters, :master_meter_id
  end
end
