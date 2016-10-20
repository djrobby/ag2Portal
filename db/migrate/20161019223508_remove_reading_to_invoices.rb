class RemoveReadingToInvoices < ActiveRecord::Migration
  def up
    remove_column :invoices, :reading_1_id
    remove_column :invoices, :reading_2_id
  end

  def down
    add_column :invoices, :reading_2_id, :integer
    add_column :invoices, :reading_1_id, :integer
  end
end
