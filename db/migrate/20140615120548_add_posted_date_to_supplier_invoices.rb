class AddPostedDateToSupplierInvoices < ActiveRecord::Migration
  def change
    add_column :supplier_invoices, :posted_at, :date

    add_index :supplier_invoices, :posted_at
  end
end
