class AddPoolToWaterConnectionContracts < ActiveRecord::Migration
  def change
    add_column :water_connection_contracts, :pool_area, :integer, limit: 3, null: false, default: 0
  end
end
