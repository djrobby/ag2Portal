class AddProjectToReceiptNoteItems < ActiveRecord::Migration
  def change
    add_column :receipt_note_items, :project_id, :integer

    add_index :receipt_note_items, :project_id
  end
end
