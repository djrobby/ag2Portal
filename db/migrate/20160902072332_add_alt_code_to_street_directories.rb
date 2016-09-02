class AddAltCodeToStreetDirectories < ActiveRecord::Migration
  def change
    add_column :street_directories, :alt_code, :string
    add_index :street_directories, :alt_code
  end
end
