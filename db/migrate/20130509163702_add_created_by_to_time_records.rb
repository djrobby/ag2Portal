class AddCreatedByToTimeRecords < ActiveRecord::Migration
  def change
    add_column :time_records, :created_by, :integer
    add_column :time_records, :updated_by, :integer
  end
end
