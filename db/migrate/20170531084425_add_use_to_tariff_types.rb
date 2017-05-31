class AddUseToTariffTypes < ActiveRecord::Migration
  def change
    add_column :tariff_types, :use_id, :integer

    add_index :tariff_types, :use_id
  end
end
