class ChangeNumberFieldsInSaleOfferItems < ActiveRecord::Migration
  def change
    change_column :sale_offer_items, :quantity, :decimal, :precision => 12, :scale => 4, :null => false, :default => '0'
    change_column :sale_offer_items, :price, :decimal, :precision => 12, :scale => 4, :null => false, :default => '0'
    change_column :sale_offer_items, :discount_pct, :decimal, :precision => 6, :scale => 2, :null => false, :default => '0'
    change_column :sale_offer_items, :discount, :decimal, :precision => 12, :scale => 4, :null => false, :default => '0'
  end
end
