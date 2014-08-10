class AddOrganizationIndexToWorkOrderLabors < ActiveRecord::Migration
  def change
    add_index :work_order_labors, :organization_id    
  end
end
