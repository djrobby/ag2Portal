class CreateComplaints < ActiveRecord::Migration
  def change
    create_table :complaints do |t|
      t.string :complaint_no
      t.references :complaint_class
      t.references :complaint_status
      t.references :client
      t.references :subscriber
      t.references :project
      t.string :description
      t.string :official_sheet
      t.timestamp :starting_at
      t.timestamp :ending_at
      t.string :answer, limit: 1000
      t.string :remarks

      t.timestamps
    end
    add_index :complaints, :complaint_class_id
    add_index :complaints, :complaint_status_id
    add_index :complaints, :client_id
    add_index :complaints, :subscriber_id
    add_index :complaints, :project_id
    add_index :complaints, :complaint_no
    add_index :complaints, :official_sheet
  end
end
