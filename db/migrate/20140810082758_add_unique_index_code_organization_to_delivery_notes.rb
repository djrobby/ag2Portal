class AddUniqueIndexCodeOrganizationToDeliveryNotes < ActiveRecord::Migration
  def change
    remove_index :delivery_notes, :delivery_no    
    add_index :delivery_notes, [:organization_id, :delivery_no], unique: true
  end
end
