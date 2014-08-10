class AddCodeIndexToWorkers < ActiveRecord::Migration
  def change
    add_index :workers, :organization_id    
    add_index :workers, :fiscal_id    
    add_index :workers, :worker_code    
  end
end
