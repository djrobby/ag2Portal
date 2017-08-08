class CreateProcessedFileTypes < ActiveRecord::Migration
  def change
    create_table :processed_file_types do |t|
      t.string :name

      t.timestamps
    end
    add_index :processed_file_types, :name
  end
end
