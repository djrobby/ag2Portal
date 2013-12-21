class ChangeAmountFieldsPrecisionInPurchase < ActiveRecord::Migration
  def change
    change_column :delivery_notes, :discount, :decimal, :precision => 13, :scale => 4, :null => false, :default => '0'
    change_column :offer_requests, :discount, :decimal, :precision => 13, :scale => 4, :null => false, :default => '0'
    change_column :offers, :discount, :decimal, :precision => 13, :scale => 4, :null => false, :default => '0'
    change_column :purchase_orders, :discount, :decimal, :precision => 13, :scale => 4, :null => false, :default => '0'
    change_column :suppliers, :max_orders_sum, :decimal, :precision => 13, :scale => 4, :null => false, :default => '0'
    change_column :receipt_notes, :discount, :decimal, :precision => 13, :scale => 4, :null => false, :default => '0'
  end
end
