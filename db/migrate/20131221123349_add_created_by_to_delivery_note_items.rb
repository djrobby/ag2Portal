class AddCreatedByToDeliveryNoteItems < ActiveRecord::Migration
  def change
    add_column :delivery_note_items, :created_by, :integer
    add_column :delivery_note_items, :updated_by, :integer
  end
end
