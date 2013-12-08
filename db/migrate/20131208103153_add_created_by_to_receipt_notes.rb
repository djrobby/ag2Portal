class AddCreatedByToReceiptNotes < ActiveRecord::Migration
  def change
    add_column :receipt_notes, :created_by, :integer
    add_column :receipt_notes, :updated_by, :integer
  end
end
