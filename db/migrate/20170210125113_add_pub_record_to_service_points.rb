class AddPubRecordToServicePoints < ActiveRecord::Migration
  def change
    add_column :service_points, :pub_record, :string

    add_index :service_points, :pub_record
  end
end
