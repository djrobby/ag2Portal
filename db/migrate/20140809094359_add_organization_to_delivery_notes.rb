class AddOrganizationToDeliveryNotes < ActiveRecord::Migration
  def change
    add_column :delivery_notes, :organization_id, :integer
  end
end
