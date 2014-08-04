class AddOrganizationToSharedContacts < ActiveRecord::Migration
  def change
    add_column :shared_contacts, :organization_id, :integer
    add_index :shared_contacts, :organization_id
  end
end
