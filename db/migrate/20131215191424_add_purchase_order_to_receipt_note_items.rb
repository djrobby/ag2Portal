class AddPurchaseOrderToReceiptNoteItems < ActiveRecord::Migration
  def change
    add_column :receipt_note_items, :purchase_order_id, :integer
    add_index :receipt_note_items, :purchase_order_id
    
    remove_index :receipt_notes, :purchase_order_id
    remove_column :receipt_notes, :purchase_order_id
  end
end
