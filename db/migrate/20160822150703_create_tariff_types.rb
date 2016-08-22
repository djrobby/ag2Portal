class CreateTariffTypes < ActiveRecord::Migration
  def change
    create_table :tariff_types do |t|
      t.string :code
      t.string :name

      t.timestamps
    end
    add_index :tariff_types, :code, unique: true
  end
end
