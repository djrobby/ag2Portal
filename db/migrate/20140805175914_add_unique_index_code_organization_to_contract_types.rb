class AddUniqueIndexCodeOrganizationToContractTypes < ActiveRecord::Migration
  def change
    remove_index :contract_types, :ct_code
    
    add_index :contract_types, [:organization_id, :ct_code], unique: true
  end
end
