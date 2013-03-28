class CreateStreetTypes < ActiveRecord::Migration
  def change
    create_table :street_types do |t|
      t.string :street_type_code
      t.string :street_type_description

      t.timestamps
    end
    add_index :street_types, :street_type_code
  end
end
