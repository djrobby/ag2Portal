class CreateTariffSchemeItems < ActiveRecord::Migration
  def change
    create_table :tariff_scheme_items do |t|
      t.references :tariff_scheme
      t.references :tariff

      t.timestamps
    end
    add_index :tariff_scheme_items, :tariff_scheme_id
    add_index :tariff_scheme_items, :tariff_id
  end
end
