class AddImageToReadings < ActiveRecord::Migration
  def change
    add_column :readings, :image, :binary, :limit => 10.megabyte

    add_column :pre_readings, :image, :binary, :limit => 10.megabyte
  end
end
