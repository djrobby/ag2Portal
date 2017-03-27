class AddTotalsToSupplierInvoices < ActiveRecord::Migration
  def self.up
    add_column :supplier_invoices, :totals, :decimal, :precision => 13, :scale => 4, :null => false, :default => 0

    SupplierInvoice.find_each do |p|
      p.update_column(:totals, p.total)
    end
  end

  def self.down
    remove_column :supplier_invoices, :totals
  end
end
