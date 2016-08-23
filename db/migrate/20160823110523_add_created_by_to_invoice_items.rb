class AddCreatedByToInvoiceItems < ActiveRecord::Migration
  def change
    add_column :invoice_items, :created_by, :integer
    add_column :invoice_items, :updated_by, :integer
  end
end
