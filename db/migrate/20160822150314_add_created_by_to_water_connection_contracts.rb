class AddCreatedByToWaterConnectionContracts < ActiveRecord::Migration
  def change
    add_column :water_connection_contracts, :created_by, :integer
    add_column :water_connection_contracts, :updated_by, :integer
  end
end
