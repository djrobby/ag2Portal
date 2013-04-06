class CreateDegreeTypes < ActiveRecord::Migration
  def change
    create_table :degree_types do |t|
      t.string :name
      t.string :dt_code

      t.timestamps
    end
    add_index :degree_types, :dt_code
  end
end
