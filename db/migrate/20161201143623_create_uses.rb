class CreateUses < ActiveRecord::Migration
  def change
    create_table :uses do |t|
      t.string :code
      t.string :name

      t.timestamps
    end
    add_index :uses, :code, unique: true
  end
end
