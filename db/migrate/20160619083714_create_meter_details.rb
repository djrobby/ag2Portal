class CreateMeterDetails < ActiveRecord::Migration
  def change
    create_table :meter_details do |t|
      t.references :meter
      t.references :subscriber
      t.date :installation_date
      t.integer :installation_reading
      t.references :meter_location
      t.date :withdrawal_date
      t.integer :withdrawal_reading

      t.timestamps
    end
    add_index :meter_details, :meter_id
    add_index :meter_details, :subscriber_id
    add_index :meter_details, :meter_location_id
    add_index :meter_details, :installation_date
    add_index :meter_details, :withdrawal_date
  end
end
