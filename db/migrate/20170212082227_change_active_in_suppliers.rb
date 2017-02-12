class ChangeActiveInSuppliers < ActiveRecord::Migration
  def change
    change_column :suppliers, :active, :boolean, null: false, default: true
  end
end
