class CreateTimerecordTypes < ActiveRecord::Migration
  def change
    create_table :timerecord_types do |t|
      t.string :name

      t.timestamps
    end
    add_index :timerecord_types, :name
  end
end
