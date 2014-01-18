class AddProjectToDeliveryNoteItems < ActiveRecord::Migration
  def change
    add_column :delivery_note_items, :project_id, :integer

    add_index :delivery_note_items, :project_id
  end
end
