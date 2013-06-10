class CreateTimerecordReports < ActiveRecord::Migration
  def change
    create_table :timerecord_reports do |t|
      t.integer :tr_worker_id
      t.date :tr_date
      t.time :tr_time_1
      t.integer :tr_type_id_1
      t.integer :tr_code_id_1
      t.time :tr_time_2
      t.integer :tr_type_id_2
      t.integer :tr_code_id_2
      t.time :tr_time_3
      t.integer :tr_type_id_3
      t.integer :tr_code_id_3
      t.time :tr_time_4
      t.integer :tr_type_id_4
      t.integer :tr_code_id_4
      t.time :tr_time_5
      t.integer :tr_type_id_5
      t.integer :tr_code_id_5
      t.time :tr_time_6
      t.integer :tr_type_id_6
      t.integer :tr_code_id_6
      t.time :tr_time_7
      t.integer :tr_type_id_7
      t.integer :tr_code_id_7
      t.time :tr_time_8
      t.integer :tr_type_id_8
      t.integer :tr_code_id_8
    end
    add_index :timerecord_reports, :tr_worker_id
    add_index :timerecord_reports, :tr_date
    add_index :timerecord_reports, :tr_type_id_1
    add_index :timerecord_reports, :tr_code_id_1
    add_index :timerecord_reports, :tr_type_id_2
    add_index :timerecord_reports, :tr_code_id_2
    add_index :timerecord_reports, :tr_type_id_3
    add_index :timerecord_reports, :tr_code_id_3
    add_index :timerecord_reports, :tr_type_id_4
    add_index :timerecord_reports, :tr_code_id_4
    add_index :timerecord_reports, :tr_type_id_5
    add_index :timerecord_reports, :tr_code_id_5
    add_index :timerecord_reports, :tr_type_id_6
    add_index :timerecord_reports, :tr_code_id_6
    add_index :timerecord_reports, :tr_type_id_7
    add_index :timerecord_reports, :tr_code_id_7
    add_index :timerecord_reports, :tr_type_id_8
    add_index :timerecord_reports, :tr_code_id_8
  end
end
