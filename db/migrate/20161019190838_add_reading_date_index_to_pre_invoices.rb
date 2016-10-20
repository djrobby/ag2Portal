class AddReadingDateIndexToPreInvoices < ActiveRecord::Migration
  def change
    add_column :pre_invoices, :reading_1_date, :date
    add_column :pre_invoices, :reading_2_date, :date
    add_column :pre_invoices, :reading_1_index, :integer
    add_column :pre_invoices, :reading_2_index, :integer
  end
end
