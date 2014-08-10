class AddUniqueIndexCodeOrganizationToReceiptNotes < ActiveRecord::Migration
  def change
    add_index :receipt_notes, :organization_id    
    add_index :receipt_notes, [:organization_id, :supplier_id, :receipt_no], unique: true, name: 'index_receipt_notes_on_organization_and_supplier_and_no'
  end
end
