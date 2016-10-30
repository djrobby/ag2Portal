class AddDeliveryNoteItemToWorkOrderItems < ActiveRecord::Migration
  def change
    add_column :work_order_items, :delivery_note_item_id, :integer

    add_index :work_order_items, :delivery_note_item_id
  end
end
