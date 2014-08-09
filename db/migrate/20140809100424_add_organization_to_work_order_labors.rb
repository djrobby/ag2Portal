class AddOrganizationToWorkOrderLabors < ActiveRecord::Migration
  def change
    add_column :work_order_labors, :organization_id, :integer
  end
end
