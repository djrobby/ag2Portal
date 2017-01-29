class AddSubscriberToReadingIndex < ActiveRecord::Migration
  def change
    remove_index :readings, name: 'index_readings_unique'
    remove_index :pre_readings, name: 'index_pre_readings_unique'

    add_index :readings,
              [:project_id, :billing_period_id, :reading_type_id, :meter_id, :subscriber_id, :reading_date],
              unique: true, name: 'index_readings_unique'
    add_index :pre_readings,
              [:project_id, :billing_period_id, :reading_type_id, :meter_id, :subscriber_id, :reading_date],
              unique: true, name: 'index_pre_readings_unique'
  end
end
