class AddCreatedByToInvoiceTypes < ActiveRecord::Migration
  def change
    add_column :invoice_types, :created_by, :integer
    add_column :invoice_types, :updated_by, :integer
  end
end
