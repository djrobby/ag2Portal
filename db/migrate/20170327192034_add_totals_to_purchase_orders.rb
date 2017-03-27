class AddTotalsToPurchaseOrders < ActiveRecord::Migration
  def self.up
    add_column :purchase_orders, :totals, :decimal, :precision => 13, :scale => 4, :null => false, :default => 0

    PurchaseOrder.find_each do |p|
      p.update_column(:totals, p.total)
    end
  end

  def self.down
    remove_column :purchase_orders, :totals
  end
end
