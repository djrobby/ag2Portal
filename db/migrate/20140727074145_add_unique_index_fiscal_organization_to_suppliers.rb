class AddUniqueIndexFiscalOrganizationToSuppliers < ActiveRecord::Migration
  def change
    remove_index :suppliers, :fiscal_id
    remove_index :suppliers, :supplier_code
    
    add_index :suppliers, [:organization_id, :fiscal_id], unique: true
    add_index :suppliers, [:organization_id, :supplier_code], unique: true
  end
end
