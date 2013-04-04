class CreateApps < ActiveRecord::Migration
  def change
    create_table :apps do |t|
      t.string :name
      t.string :description
      t.references :site
      t.string :path
      t.string :pict_file
      t.string :icon_file

      t.timestamps
    end
    add_index :apps, :site_id
    add_index :apps, :name
  end
end
