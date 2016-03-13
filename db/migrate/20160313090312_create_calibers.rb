class CreateCalibers < ActiveRecord::Migration
  def change
    create_table :calibers do |t|
      t.integer :caliber

      t.timestamps
    end
    add_index :calibers, :caliber
  end
end
