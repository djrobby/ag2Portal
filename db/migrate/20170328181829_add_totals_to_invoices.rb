class AddTotalsToInvoices < ActiveRecord::Migration
  def self.up
    add_column :invoices, :totals, :decimal, :precision => 13, :scale => 4, :null => false, :default => 0

    Invoice.find_each do |p|
      p.update_column(:totals, p.total)
    end
  end

  def self.down
    remove_column :invoices, :totals
  end
end
