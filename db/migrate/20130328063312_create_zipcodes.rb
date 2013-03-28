class CreateZipcodes < ActiveRecord::Migration
  def change
    create_table :zipcodes do |t|
      t.string :zipcode
      t.references :town
      t.references :province

      t.timestamps
    end
    add_index :zipcodes, :zipcode
    add_index :zipcodes, :town_id
    add_index :zipcodes, :province_id
  end
end
