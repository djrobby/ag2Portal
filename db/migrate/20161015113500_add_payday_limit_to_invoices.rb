class AddPaydayLimitToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :payday_limit, :date
  end
end
