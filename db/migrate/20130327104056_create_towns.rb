class CreateTowns < ActiveRecord::Migration
  def change
    create_table :towns do |t|
      t.string :name
      t.string :ine_cmun
      t.string :ine_dc
      t.references :province

      t.timestamps
    end
    add_index :towns, :province_id
    add_index :towns, :ine_cmun
  end
end
