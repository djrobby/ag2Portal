class AddTaxesToInvoices < ActiveRecord::Migration
  def self.up
    add_column :invoices, :total_taxes, :decimal, :precision => 13, :scale => 4, :null => false, :default => 0
    add_column :invoices, :old_no, :string
    add_index :invoices, :old_no

    Invoice.find_each do |p|
      p.update_column(:total_taxes, p.taxes)
    end
  end

  def self.down
    remove_column :invoices, :total_taxes
    remove_index :invoices, :old_no
    remove_column :invoices, :old_no
  end
end
