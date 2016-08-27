class AddIndexesToInvoices < ActiveRecord::Migration
  def change
    add_index :invoices, :invoice_no
    add_index :invoices, :invoice_date
  end
end
