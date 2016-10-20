class AddReading1IdToReadings < ActiveRecord::Migration
  def change
    add_column :readings, :reading_1_id, :integer
    add_column :readings, :reading_2_id, :integer
  end
end
