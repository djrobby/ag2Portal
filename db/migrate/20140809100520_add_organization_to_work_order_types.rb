class AddOrganizationToWorkOrderTypes < ActiveRecord::Migration
  def change
    add_column :work_order_types, :organization_id, :integer
  end
end
