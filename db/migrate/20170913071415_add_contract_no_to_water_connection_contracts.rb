class AddContractNoToWaterConnectionContracts < ActiveRecord::Migration
  def change
    add_column :water_connection_contracts, :contract_no, :string
    add_index :water_connection_contracts, :contract_no
  end
end
