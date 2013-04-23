class CreateTimerecordCodes < ActiveRecord::Migration
  def change
    create_table :timerecord_codes do |t|
      t.string :name

      t.timestamps
    end
    add_index :timerecord_codes, :name
  end
end
