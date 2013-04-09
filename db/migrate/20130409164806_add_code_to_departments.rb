class AddCodeToDepartments < ActiveRecord::Migration
  def change
    add_column :departments, :code, :string

    add_index :departments, :code
  end
end
