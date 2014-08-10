class AddCodeIndexToCollectiveAgreements < ActiveRecord::Migration
  def change
    add_index :collective_agreements, :organization_id    
    add_index :collective_agreements, :ca_code    
  end
end
