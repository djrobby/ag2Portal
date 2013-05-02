class AddRegionToSharedContacts < ActiveRecord::Migration
  def change
    add_column :shared_contacts, :region_id, :integer

    add_index :shared_contacts, :region_id
  end
end
