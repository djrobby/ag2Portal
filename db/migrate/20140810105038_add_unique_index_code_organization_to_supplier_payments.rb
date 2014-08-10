class AddUniqueIndexCodeOrganizationToSupplierPayments < ActiveRecord::Migration
  def change
    add_index :supplier_payments, :organization_id    
    add_index :supplier_payments, [:organization_id, :payment_no], unique: true
  end
end
