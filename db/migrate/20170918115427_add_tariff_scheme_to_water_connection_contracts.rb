class AddTariffSchemeToWaterConnectionContracts < ActiveRecord::Migration
  def change
    add_column :water_connection_contracts, :tariff_scheme_id, :integer
  end
end
