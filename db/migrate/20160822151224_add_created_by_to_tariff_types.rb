class AddCreatedByToTariffTypes < ActiveRecord::Migration
  def change
    add_column :tariff_types, :created_by, :integer
    add_column :tariff_types, :updated_by, :integer
  end
end
