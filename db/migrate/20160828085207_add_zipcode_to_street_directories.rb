class AddZipcodeToStreetDirectories < ActiveRecord::Migration
  def change
    add_column :street_directories, :zipcode_id, :integer

    add_index :street_directories, :zipcode_id
  end
end
