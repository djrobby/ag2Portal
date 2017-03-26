class AddTotalsToOffers < ActiveRecord::Migration
  def self.up
    add_column :offers, :totals, :decimal, :precision => 13, :scale => 4, :null => false, :default => 0

    Offer.find_each do |p|
      p.update_column(:totals, p.total)
    end
  end

  def self.down
    remove_column :offers, :totals
  end
end
