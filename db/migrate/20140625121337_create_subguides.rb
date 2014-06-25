class CreateSubguides < ActiveRecord::Migration
  def change
    create_table :subguides do |t|
      t.references :guide
      t.string :name
      t.string :description
      t.text :body, :limit => 16777215
      t.integer :sort_order

      t.timestamps
    end
    add_index :subguides, :guide_id
    add_index :subguides, :name, unique: true
    add_index :subguides, :sort_order
  end
end
