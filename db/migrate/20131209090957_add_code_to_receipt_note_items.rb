class AddCodeToReceiptNoteItems < ActiveRecord::Migration
  def change
    add_column :receipt_note_items, :code, :string
    add_index :receipt_note_items, :code
  end
end
