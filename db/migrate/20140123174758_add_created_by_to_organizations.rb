class AddCreatedByToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :created_by, :integer
    add_column :organizations, :updated_by, :integer
  end
end
