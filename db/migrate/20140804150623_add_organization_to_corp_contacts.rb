class AddOrganizationToCorpContacts < ActiveRecord::Migration
  def change
    add_column :corp_contacts, :organization_id, :integer
    add_index :corp_contacts, :organization_id
  end
end
