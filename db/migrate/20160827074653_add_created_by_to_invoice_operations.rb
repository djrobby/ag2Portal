class AddCreatedByToInvoiceOperations < ActiveRecord::Migration
  def change
    add_column :invoice_operations, :created_by, :integer
    add_column :invoice_operations, :updated_by, :integer
  end
end
