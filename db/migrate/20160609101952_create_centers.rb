class CreateCenters < ActiveRecord::Migration
  def change
    create_table :centers do |t|
      t.references :town
      t.string :name
      t.boolean :active

      t.timestamps
    end
    add_index :centers, :town_id
  end
end
