class AddCreatedByToDeliveryNotes < ActiveRecord::Migration
  def change
    add_column :delivery_notes, :created_by, :integer
    add_column :delivery_notes, :updated_by, :integer
  end
end
