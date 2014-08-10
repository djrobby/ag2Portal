class AddUniqueIndexCodeOrganizationToPurchaseOrders < ActiveRecord::Migration
  def change
    add_index :purchase_orders, :organization_id    
    add_index :purchase_orders, [:organization_id, :order_no], unique: true
  end
end
