class RenameFileTypeInProcessed < ActiveRecord::Migration
  def change
    remove_index :processed_files, :filetype

    rename_column :processed_files, :filetype, :processed_file_type_id

    add_index :processed_files, :processed_file_type_id
  end
end
