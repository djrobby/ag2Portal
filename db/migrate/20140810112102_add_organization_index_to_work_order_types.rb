class AddOrganizationIndexToWorkOrderTypes < ActiveRecord::Migration
  def change
    add_index :work_order_types, :organization_id    
  end
end
