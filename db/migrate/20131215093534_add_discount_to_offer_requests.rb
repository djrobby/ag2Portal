class AddDiscountToOfferRequests < ActiveRecord::Migration
  def change
    add_column :offer_requests, :discount_pct, :decimal, :precision => 6, :scale => 2, :null => false, :default => '0'
    add_column :offer_requests, :discount, :decimal, :precision => 12, :scale => 4, :null => false, :default => '0'
  end
end
