class CreateInstalmentInvoices < ActiveRecord::Migration
  def change
    create_table :instalment_invoices do |t|
      t.references :instalment
      t.references :bill
      t.references :invoice
      t.decimal :debt, :precision => 13, :scale => 4, :null => false, :default => 0
      t.decimal :amount, :precision => 13, :scale => 4, :null => false, :default => 0

      t.timestamps
    end
    add_index :instalment_invoices, :instalment_id
    add_index :instalment_invoices, :bill_id
    add_index :instalment_invoices, :invoice_id
  end
end
