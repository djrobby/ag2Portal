class AddOrganizationToWorkerTypes < ActiveRecord::Migration
  def change
    add_column :worker_types, :organization_id, :integer
    add_index :worker_types, :organization_id
  end
end
