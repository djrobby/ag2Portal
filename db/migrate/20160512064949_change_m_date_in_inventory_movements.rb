class ChangeMDateInInventoryMovements < ActiveRecord::Migration
  def change
    change_column :inventory_movements, :mdate, :datetime
  end
end
