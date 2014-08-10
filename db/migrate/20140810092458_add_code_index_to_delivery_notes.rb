class AddCodeIndexToDeliveryNotes < ActiveRecord::Migration
  def change
    add_index :delivery_notes, :organization_id    
    add_index :delivery_notes, :delivery_no    
  end
end
