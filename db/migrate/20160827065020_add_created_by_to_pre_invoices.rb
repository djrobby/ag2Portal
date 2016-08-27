class AddCreatedByToPreInvoices < ActiveRecord::Migration
  def change
    add_column :pre_invoices, :created_by, :integer
    add_column :pre_invoices, :updated_by, :integer
  end
end
