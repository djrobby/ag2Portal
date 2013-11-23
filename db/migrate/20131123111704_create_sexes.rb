class CreateSexes < ActiveRecord::Migration
  def change
    create_table :sexes do |t|
      t.string :name

      t.timestamps
    end
    add_index :sexes, :name
  end
end
