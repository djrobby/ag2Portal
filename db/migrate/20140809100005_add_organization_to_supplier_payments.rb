class AddOrganizationToSupplierPayments < ActiveRecord::Migration
  def change
    add_column :supplier_payments, :organization_id, :integer
  end
end
