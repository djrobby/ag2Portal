class AddProjectToSupplierInvoiceItems < ActiveRecord::Migration
  def change
    add_column :supplier_invoice_items, :project_id, :integer

    add_index :supplier_invoice_items, :project_id
  end
end
