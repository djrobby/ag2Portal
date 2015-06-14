class AddAttachmentAttachmentToSupplierInvoices < ActiveRecord::Migration
  def self.up
    change_table :supplier_invoices do |t|
      t.attachment :attachment
    end
  end

  def self.down
    drop_attached_file :supplier_invoices, :attachment
  end
end
