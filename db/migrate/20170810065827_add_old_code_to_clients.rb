class AddOldCodeToClients < ActiveRecord::Migration
  def change
    add_column :clients, :old_code, :string
    add_index :clients, :old_code
  end
end
