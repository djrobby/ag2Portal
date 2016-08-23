class CreatePreReadings < ActiveRecord::Migration
  def change
    create_table :pre_readings do |t|

      t.timestamps
    end
  end
  def change
    create_table :pre_readings do |t|
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
      t.references :reading_1
      t.references :reading_2
      t.integer :reading_index_1
      t.integer :reading_index_2

      t.timestamps
    end
    add_index :pre_readings, :project_id
    add_index :pre_readings, :billing_period_id
    add_index :pre_readings, :billing_frequency_id
    add_index :pre_readings, :reading_type_id
    add_index :pre_readings, :meter_id
    add_index :pre_readings, :subscriber_id
    add_index :pre_readings, :reading_route_id
    add_index :pre_readings, :reading_date
    add_index :pre_readings,
              [:project_id, :billing_period_id, :reading_type_id, :meter_id, :reading_date],
              unique: true, name: 'index_pre_readings_unique'
    add_index :pre_readings, :reading_1_id
    add_index :pre_readings, :reading_2_id
  end
end
