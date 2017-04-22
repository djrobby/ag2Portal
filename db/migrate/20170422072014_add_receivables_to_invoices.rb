class AddReceivablesToInvoices < ActiveRecord::Migration
  def self.up
    add_column :invoices, :receivables, :decimal, :precision => 13, :scale => 4, :null => false, :default => 0

    Invoice.find_each do |p|
      p.update_column(:receivables, p.receivable)
    end
  end

  def self.down
    remove_column :invoices, :receivables
  end
end
