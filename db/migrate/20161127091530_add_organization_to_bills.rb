class AddOrganizationToBills < ActiveRecord::Migration
  def change
    add_column :bills, :organization_id, :integer
    add_column :invoices, :organization_id, :integer

    add_index :bills, :organization_id
    add_index :invoices, :organization_id
  end
end
