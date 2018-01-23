class AddTotalsToInventoryCounts < ActiveRecord::Migration
  def self.up
    add_column :inventory_counts, :totals, :decimal, :precision => 13, :scale => 4, :null => false, :default => 0
    add_column :inventory_counts, :quantities, :decimal, :precision => 13, :scale => 4, :null => false, :default => 0

    InventoryCount.find_each do |p|
      p.update_column(:totals, p.total)
      p.update_column(:quantities, p.quantity)
    end
  end

  def self.down
    remove_column :inventory_counts, :totals
    remove_column :inventory_counts, :quantities
  end
end
