class AddLetterToMeterBrands < ActiveRecord::Migration
  def change
    add_column :meter_brands, :letter_id, :string, :limit => 1
  end
end
