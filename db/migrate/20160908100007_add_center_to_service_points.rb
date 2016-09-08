class AddCenterToServicePoints < ActiveRecord::Migration
  def change
    add_column :service_points, :center_id, :integer
    add_index :service_points, :center_id
  end
end
