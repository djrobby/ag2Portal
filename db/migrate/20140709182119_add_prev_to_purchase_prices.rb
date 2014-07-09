class AddPrevToPurchasePrices < ActiveRecord::Migration
  def change
    add_column :purchase_prices, :prev_code, :string
    add_column :purchase_prices, :prev_price, :decimal, :precision => 12, :scale => 4, :null => false, :default => '0'
  end
end
