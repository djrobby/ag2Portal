class AddDiameterWaterConnectionContracts < ActiveRecord::Migration
  def change
    add_column :water_connection_contracts, :diameter, :integer, limit: 2, null: false, default: 0
  end
end
