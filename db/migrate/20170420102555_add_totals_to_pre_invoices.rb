class AddTotalsToPreInvoices < ActiveRecord::Migration
  def self.up
    add_column :pre_invoices, :totals, :decimal, :precision => 13, :scale => 4, :null => false, :default => 0

    PreInvoice.find_each do |p|
      p.update_column(:totals, p.total)
    end
  end

  def self.down
    remove_column :pre_invoices, :totals
  end
end
