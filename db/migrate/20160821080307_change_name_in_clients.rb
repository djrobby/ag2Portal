class ChangeNameInClients < ActiveRecord::Migration
  def change
    remove_index :clients, :name
    remove_column :clients, :name

    add_column :clients, :first_name, :string
    add_index :clients, :first_name
    add_column :clients, :last_name, :string
    add_index :clients, :last_name
    add_column :clients, :company, :string
    add_index :clients, :company
  end
end
