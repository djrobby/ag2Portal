class AddInvoicesCountToBills < ActiveRecord::Migration
  def self.up
    add_column :bills, :invoices_count, :integer, :default => 0

    Bill.reset_column_information
    Bill.find_each do |p|
      Bill.reset_counters p.id, :invoices
    end
  end

  def self.down
    remove_column :bills, :invoices_count
  end
end
