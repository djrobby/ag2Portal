class AddPurchaseOrderToReceiptNotes < ActiveRecord::Migration
  def change
    add_column :receipt_notes, :purchase_order_id, :integer
    add_index :receipt_notes, :purchase_order_id
  end
end
