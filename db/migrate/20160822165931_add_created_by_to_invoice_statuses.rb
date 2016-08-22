class AddCreatedByToInvoiceStatuses < ActiveRecord::Migration
  def change
    add_column :invoice_statuses, :created_by, :integer
    add_column :invoice_statuses, :updated_by, :integer
  end
end
