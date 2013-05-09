class AddCreatedByToSites < ActiveRecord::Migration
  def change
    add_column :sites, :created_by, :integer
    add_column :sites, :updated_by, :integer
  end
end
