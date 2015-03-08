class AddMaxOrderToOffices < ActiveRecord::Migration
  def change
    add_column :offices, :max_order_total, :decimal, :precision => 13, :scale => 4, :null => false, :default => '0'
    add_column :offices, :max_order_price, :decimal, :precision => 12, :scale => 4, :null => false, :default => '0'
  end
end
