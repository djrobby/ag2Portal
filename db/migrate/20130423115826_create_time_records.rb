class CreateTimeRecords < ActiveRecord::Migration
  def change
    create_table :time_records do |t|
      t.date :timerecord_date
      t.time :timerecord_time
      t.references :worker
      t.references :timerecord_type
      t.references :timerecord_code

      t.timestamps
    end
    add_index :time_records, :worker_id
    add_index :time_records, :timerecord_type_id
    add_index :time_records, :timerecord_code_id
    add_index :time_records, :timerecord_date
    add_index :time_records, :timerecord_time
  end
end
