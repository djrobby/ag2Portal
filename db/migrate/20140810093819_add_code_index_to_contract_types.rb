class AddCodeIndexToContractTypes < ActiveRecord::Migration
  def change
    add_index :contract_types, :organization_id    
    add_index :contract_types, :ct_code    
  end
end
