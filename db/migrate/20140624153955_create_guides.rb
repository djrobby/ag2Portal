class CreateGuides < ActiveRecord::Migration
  def change
    create_table :guides do |t|
      t.references :site
      t.references :app
      t.string :name
      t.string :description
      t.text :body, :limit => 16777215

      t.timestamps
    end
    add_index :guides, :site_id
    add_index :guides, :app_id
    add_index :guides, :name, unique: true
  end
end
