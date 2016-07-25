class ChangeFloorInStores < ActiveRecord::Migration
  def change
    change_column :stores, :floor, :string
  end
end
