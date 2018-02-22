class AddSubtotalsToInvoices < ActiveRecord::Migration
  def self.up
    add_column :invoices, :subtotals, :decimal, :precision => 13, :scale => 4, :null => false, :default => 0
    add_column :invoices, :bonuses, :decimal, :precision => 13, :scale => 4, :null => false, :default => 0
    add_column :invoices, :taxables, :decimal, :precision => 13, :scale => 4, :null => false, :default => 0

    Invoice.find_each do |p|
      p.update_column(:subtotals, p.subtotal)
      p.update_column(:bonuses, p.bonus)
      p.update_column(:taxables, p.taxable)
    end
  end

  def self.down
    remove_column :invoices, :subtotals
    remove_column :invoices, :bonuses
    remove_column :invoices, :taxables
  end
end
