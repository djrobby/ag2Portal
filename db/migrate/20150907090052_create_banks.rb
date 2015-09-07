class CreateBanks < ActiveRecord::Migration
  def change
    create_table :banks do |t|
      t.string :code
      t.string :name
      t.string :swift

      t.timestamps
    end
    add_index :banks, :code
    add_index :banks, :name
    add_index :banks, :swift
  end
end
