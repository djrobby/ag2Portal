class ChangeReadingDatesInInvoices < ActiveRecord::Migration
  def change
    change_column :invoices, :reading_1_date, :timestamp
    change_column :invoices, :reading_2_date, :timestamp
  end
end
