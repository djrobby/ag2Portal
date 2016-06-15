class AddCreatedByToMeterBrands < ActiveRecord::Migration
  def change
    add_column :meter_brands, :created_by, :integer
    add_column :meter_brands, :updated_by, :integer
  end
end
