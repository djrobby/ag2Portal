class AddReceiptNoteToSupplierInvoices < ActiveRecord::Migration
  def change
    add_column :supplier_invoices, :receipt_note_id, :integer
    add_index :supplier_invoices, :receipt_note_id
  end
end
