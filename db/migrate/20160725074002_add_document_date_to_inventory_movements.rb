class AddDocumentDateToInventoryMovements < ActiveRecord::Migration
  def change
    add_column :inventory_movements, :ddate, :date
    add_column :inventory_movements, :adate, :datetime

    add_index :inventory_movements, :mdate
    add_index :inventory_movements, :ddate
    add_index :inventory_movements, :adate
  end
end
