class AddUniqueIndexCodeOrganizationToWorkOrders < ActiveRecord::Migration
  def change
    add_index :work_orders, [:organization_id, :order_no], unique: true
  end
end
