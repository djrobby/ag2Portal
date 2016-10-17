class AddPaydayLimitToPreInvoices < ActiveRecord::Migration
  def change
    add_column :pre_invoices, :payday_limit, :date
  end
end
