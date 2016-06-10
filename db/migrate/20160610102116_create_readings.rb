class CreateReadings < ActiveRecord::Migration
  def change
    create_table :readings do |t|
      t.references :project
      t.references :billing_period
      t.references :billing_frequency
      t.references :reading_type
      t.references :meter
      t.references :subscriber
      t.references :reading_route
      t.integer :reading_sequence
      t.string :reading_variant
      t.timestamp :reading_date
      t.integer :reading_index

      t.timestamps
    end
    add_index :readings, :project_id
    add_index :readings, :billing_period_id
    add_index :readings, :billing_frequency_id
    add_index :readings, :reading_type_id
    add_index :readings, :meter_id
    add_index :readings, :subscriber_id
    add_index :readings, :reading_route_id
    add_index :readings, :reading_date
    add_index :readings,
              [:project_id, :billing_period_id, :reading_type_id, :meter_id, :reading_date],
              unique: true, name: 'index_readings_unique'
  end
end
