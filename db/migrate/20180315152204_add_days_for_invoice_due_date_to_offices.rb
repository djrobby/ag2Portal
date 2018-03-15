class AddDaysForInvoiceDueDateToOffices < ActiveRecord::Migration
  def change
    add_column :offices, :days_for_invoice_due_date, :integer, limit: 2, null: false, default: 0
  end
end
