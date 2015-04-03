class ChangeFloorInSuppliers < ActiveRecord::Migration
  def change
    change_column :suppliers, :floor, :string
  end
end
