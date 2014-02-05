class AddIpToTimeRecords < ActiveRecord::Migration
  def change
    add_column :time_records, :source_ip, :string
  end
end
