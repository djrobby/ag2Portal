class CreateStreetDirectories < ActiveRecord::Migration
  def change
    create_table :street_directories do |t|
      t.references :town
      t.references :street_type
      t.string :street_name

      t.timestamps
    end
    add_index :street_directories, :town_id
    add_index :street_directories, :street_type_id
    add_index :street_directories, :street_name
  end
end
