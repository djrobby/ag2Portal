class CreateAreas < ActiveRecord::Migration
  def change
    create_table :areas do |t|
      t.string :name
      t.references :department

      t.timestamps
    end
    add_index :areas, :department_id
    add_index :areas, :name
  end
end
