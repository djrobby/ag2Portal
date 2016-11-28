class AddCreatedByIndexToPurchaseOrders < ActiveRecord::Migration
  def change
    add_index :purchase_orders, :created_by
  end
end
