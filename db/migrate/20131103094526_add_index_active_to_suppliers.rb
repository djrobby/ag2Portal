class AddIndexActiveToSuppliers < ActiveRecord::Migration
  def change
    add_index :suppliers, :active
  end
end
