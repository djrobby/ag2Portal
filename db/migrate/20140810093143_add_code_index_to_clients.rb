class AddCodeIndexToClients < ActiveRecord::Migration
  def change
    add_index :clients, :organization_id    
    add_index :clients, :fiscal_id    
    add_index :clients, :client_code    
  end
end
