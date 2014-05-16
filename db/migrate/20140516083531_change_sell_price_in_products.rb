class ChangeSellPriceInProducts < ActiveRecord::Migration
  def change
    change_column :products, :sell_price, :decimal, :precision => 12, :scale => 4, :null => false, :default => '0'
  end
end
