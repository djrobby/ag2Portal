class AddOrganizationToWorkOrders < ActiveRecord::Migration
  def change
    add_column :work_orders, :organization_id, :integer

    add_index :work_orders, :organization_id
  end
end
