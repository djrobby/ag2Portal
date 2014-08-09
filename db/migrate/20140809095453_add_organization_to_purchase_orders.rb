class AddOrganizationToPurchaseOrders < ActiveRecord::Migration
  def change
    add_column :purchase_orders, :organization_id, :integer
  end
end
