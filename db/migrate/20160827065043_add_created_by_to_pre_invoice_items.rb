class AddCreatedByToPreInvoiceItems < ActiveRecord::Migration
  def change
    add_column :pre_invoice_items, :created_by, :integer
    add_column :pre_invoice_items, :updated_by, :integer
  end
end
