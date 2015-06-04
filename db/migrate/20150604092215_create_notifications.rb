class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.string :name
      t.string :table
      t.integer :action

      t.timestamps
    end
    add_index :notifications, :table
    add_index :notifications, :action
  end
end
