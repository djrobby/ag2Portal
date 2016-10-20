class RemoveReadingToPreInvoices < ActiveRecord::Migration
  def up
    remove_column :pre_invoices, :reading_1_id
    remove_column :pre_invoices, :reading_2_id
  end

  def down
    add_column :pre_invoices, :reading_2_id, :integer
    add_column :pre_invoices, :reading_1_id, :integer
  end
end
