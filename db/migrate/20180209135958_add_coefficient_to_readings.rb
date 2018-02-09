class AddCoefficientToReadings < ActiveRecord::Migration
  def change
    add_column :readings, :coefficient, :integer, limit: 2, null: false, default: 1
  end
end
