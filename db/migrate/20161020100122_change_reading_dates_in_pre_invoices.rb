class ChangeReadingDatesInPreInvoices < ActiveRecord::Migration
  def change
    change_column :pre_invoices, :reading_1_date, :timestamp
    change_column :pre_invoices, :reading_2_date, :timestamp
  end
end
