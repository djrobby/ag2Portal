class AddCreatedByToWaterConnections < ActiveRecord::Migration
  def change
    add_column :water_connections, :created_by, :integer
    add_column :water_connections, :updated_by, :integer
  end
end
