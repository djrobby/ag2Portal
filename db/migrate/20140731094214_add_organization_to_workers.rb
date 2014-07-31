class AddOrganizationToWorkers < ActiveRecord::Migration
  def change
    add_column :workers, :organization_id, :integer
  end
end
