class AddTotalsToOfferRequests < ActiveRecord::Migration
  def self.up
    add_column :offer_requests, :totals, :decimal, :precision => 13, :scale => 4, :null => false, :default => 0

    OfferRequest.find_each do |p|
      p.update_column(:totals, p.total)
    end
  end

  def self.down
    remove_column :offer_requests, :totals
  end
end
