class AddCreatedByToRegions < ActiveRecord::Migration
  def change
    add_column :regions, :created_by, :integer
    add_column :regions, :updated_by, :integer
  end
end
