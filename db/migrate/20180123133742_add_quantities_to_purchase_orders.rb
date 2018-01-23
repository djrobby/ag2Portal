class AddQuantitiesToPurchaseOrders < ActiveRecord::Migration
  def self.up
    add_column :purchase_orders, :quantities, :decimal, :precision => 13, :scale => 4, :null => false, :default => 0
    add_column :purchase_orders, :balances, :decimal, :precision => 13, :scale => 4, :null => false, :default => 0

    PurchaseOrder.find_each do |p|
      p.update_column(:quantities, p.quantity)
      p.update_column(:balances, p.balance)
    end
  end

  def self.down
    remove_column :purchase_orders, :quantities
    remove_column :purchase_orders, :balances
  end
end
