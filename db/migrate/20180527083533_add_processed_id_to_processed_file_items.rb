class AddProcessedIdToProcessedFileItems < ActiveRecord::Migration
  def change
    add_column :processed_file_items, :processed_model, :string
    add_index :processed_file_items, :processed_model
    add_column :processed_file_items, :processed_id, :integer
    add_index :processed_file_items, :processed_id
  end
end
