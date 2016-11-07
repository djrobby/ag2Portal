class CreateFormalities < ActiveRecord::Migration
  def change
    create_table :formalities do |t|
      t.references :formality_type
      t.string :code
      t.string :name

      t.timestamps
    end
    add_index :formalities, :formality_type_id
    add_index :formalities, :code
    add_index :formalities, :name
  end
end
