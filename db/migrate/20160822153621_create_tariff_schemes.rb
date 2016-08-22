class CreateTariffSchemes < ActiveRecord::Migration
  def change
    create_table :tariff_schemes do |t|
      t.references :project
      t.string :name
      t.references :tariff_type
      t.date :starting_at
      t.date :ending_at

      t.timestamps
    end
    add_index :tariff_schemes, :project_id
    add_index :tariff_schemes, :tariff_type_id
  end
end
