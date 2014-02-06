class AddOrganizationToEntities < ActiveRecord::Migration
  def change
    add_column :entities, :organization_id, :integer

    add_index :entities, :organization_id
  end
end
