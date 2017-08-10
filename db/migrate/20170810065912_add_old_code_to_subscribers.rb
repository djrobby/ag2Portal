class AddOldCodeToSubscribers < ActiveRecord::Migration
  def change
    add_column :subscribers, :old_code, :string
    add_index :subscribers, :old_code
  end
end
