class AddCreatedByToTariffSchemes < ActiveRecord::Migration
  def change
    add_column :tariff_schemes, :created_by, :integer
    add_column :tariff_schemes, :updated_by, :integer
  end
end
