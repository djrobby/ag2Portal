class AddPaydayLimitToSupplierInvoices < ActiveRecord::Migration
  def change
    add_column :supplier_invoices, :payday_limit, :date
  end
end
