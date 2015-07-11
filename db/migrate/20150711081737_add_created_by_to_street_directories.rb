class AddCreatedByToStreetDirectories < ActiveRecord::Migration
  def change
    add_column :street_directories, :created_by, :integer
    add_column :street_directories, :updated_by, :integer
  end
end
