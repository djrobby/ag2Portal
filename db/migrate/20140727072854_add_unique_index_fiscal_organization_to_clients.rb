class AddUniqueIndexFiscalOrganizationToClients < ActiveRecord::Migration
  def change
    remove_index :clients, :fiscal_id
    remove_index :clients, :client_code
    
    add_index :clients, [:organization_id, :fiscal_id], unique: true
    add_index :clients, [:organization_id, :client_code], unique: true
  end
end
