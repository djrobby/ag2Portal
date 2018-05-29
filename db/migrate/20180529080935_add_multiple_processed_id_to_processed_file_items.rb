class AddMultipleProcessedIdToProcessedFileItems < ActiveRecord::Migration
  def change
    add_column :processed_file_items, :multiple_processed_id, :string
    add_index :processed_file_items, :multiple_processed_id
  end
end
