class CreateProcessedFiles < ActiveRecord::Migration
  def change
    create_table :processed_files do |t|
      t.string :filename
      t.integer :filetype
      t.integer :flow, :limit => 2

      t.timestamps
    end
    add_index :processed_files, :filename
    add_index :processed_files, :filetype
    add_index :processed_files, :flow
  end
end
