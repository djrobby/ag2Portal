class AddOrganizationToZones < ActiveRecord::Migration
  def change
    add_column :zones, :organization_id, :integer

    add_index :zones, :organization_id
  end
end
