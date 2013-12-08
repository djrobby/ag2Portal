class AddCreatedByToReceiptNoteItems < ActiveRecord::Migration
  def change
    add_column :receipt_note_items, :created_by, :integer
    add_column :receipt_note_items, :updated_by, :integer
  end
end
