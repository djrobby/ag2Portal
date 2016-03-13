class AddIndexCodeToMeters < ActiveRecord::Migration
  def change
    add_index :meters, :meter_code
  end
end
