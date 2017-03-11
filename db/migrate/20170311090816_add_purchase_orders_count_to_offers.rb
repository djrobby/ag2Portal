class AddPurchaseOrdersCountToOffers < ActiveRecord::Migration
  def self.up
    add_column :offers, :purchase_orders_count, :integer, :default => 0

    Offer.reset_column_information
    Offer.find_each do |p|
      Offer.reset_counters p.id, :purchase_orders
    end
  end

  def self.down
    remove_column :offers, :purchase_orders_count
  end
end
