class AddTaxesToSupplierInvoices < ActiveRecord::Migration
  def self.up
    add_column :supplier_invoices, :taxables, :decimal, :precision => 13, :scale => 4, :null => false, :default => 0
    add_column :supplier_invoices, :total_taxes, :decimal, :precision => 13, :scale => 4, :null => false, :default => 0

    SupplierInvoice.find_each do |p|
      p.update_column(:taxables, p.taxable)
      p.update_column(:total_taxes, p.taxes)
    end
  end

  def self.down
    remove_column :supplier_invoices, :taxables
    remove_column :supplier_invoices, :total_taxes
  end
end
