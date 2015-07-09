class AddCreatedByToSupplierPayments < ActiveRecord::Migration
  def change
    add_column :supplier_payments, :created_by, :integer
    add_column :supplier_payments, :updated_by, :integer
  end
end
