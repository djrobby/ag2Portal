class AddReadingDateIndexToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :reading_1_date, :date
    add_column :invoices, :reading_2_date, :date
    add_column :invoices, :reading_1_index, :integer
    add_column :invoices, :reading_2_index, :integer
  end
end
