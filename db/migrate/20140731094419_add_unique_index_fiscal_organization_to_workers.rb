class AddUniqueIndexFiscalOrganizationToWorkers < ActiveRecord::Migration
  def change
    remove_index :workers, :fiscal_id
    remove_index :workers, :worker_code
    
    add_index :workers, [:organization_id, :fiscal_id], unique: true
    add_index :workers, [:organization_id, :worker_code]
  end
end
