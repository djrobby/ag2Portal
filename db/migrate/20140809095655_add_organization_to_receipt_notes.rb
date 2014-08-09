class AddOrganizationToReceiptNotes < ActiveRecord::Migration
  def change
    add_column :receipt_notes, :organization_id, :integer
  end
end
