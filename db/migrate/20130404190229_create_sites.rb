class CreateSites < ActiveRecord::Migration
  def change
    create_table :sites do |t|
      t.string :name
      t.string :description
      t.string :path
      t.string :pict_file
      t.string :icon_file

      t.timestamps
    end
    add_index :sites, :name
  end
end
