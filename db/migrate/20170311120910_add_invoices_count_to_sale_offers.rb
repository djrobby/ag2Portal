class AddInvoicesCountToSaleOffers < ActiveRecord::Migration
  def self.up
    add_column :sale_offers, :invoices_count, :integer, :default => 0

    SaleOffer.reset_column_information
    SaleOffer.find_each do |p|
      SaleOffer.reset_counters p.id, :invoices
    end
  end

  def self.down
    remove_column :sale_offers, :invoices_count
  end
end
