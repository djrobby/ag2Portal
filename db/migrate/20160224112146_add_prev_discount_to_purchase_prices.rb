class AddPrevDiscountToPurchasePrices < ActiveRecord::Migration
  def change
    add_column :purchase_prices, :prev_discount_rate, :decimal, :precision => 12, :scale => 2, :null => false, :default => '0'
  end
end
