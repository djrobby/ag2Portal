class CreateProcessedFileItems < ActiveRecord::Migration
  def change
    create_table :processed_file_items do |t|
      t.references :processed_file
      t.integer :item_type
      t.string :item_model
      t.integer :item_id
      t.string :subitem_model
      t.integer :subitem_id
      t.decimal :item_amount, :precision => 13, :scale => 4, :null => false, :default => 0
      t.string :item_remarks
    end
    add_index :processed_file_items, :processed_file_id
    add_index :processed_file_items, :item_type
    add_index :processed_file_items, :item_model
    add_index :processed_file_items, :item_id
    add_index :processed_file_items, :subitem_model
    add_index :processed_file_items, :subitem_id
  end
end
