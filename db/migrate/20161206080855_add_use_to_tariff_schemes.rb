class AddUseToTariffSchemes < ActiveRecord::Migration
  def change
    add_column :tariff_schemes, :use_id, :integer

    add_index :tariff_schemes, :use_id
  end
end
