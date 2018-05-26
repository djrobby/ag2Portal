class AddFileIdToProcessedFiles < ActiveRecord::Migration
  def change
    add_column :processed_files, :fileid, :string
    add_index :processed_files, :fileid
  end
end
