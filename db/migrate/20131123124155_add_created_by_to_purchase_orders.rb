class AddCreatedByToPurchaseOrders < ActiveRecord::Migration
  def change
    add_column :purchase_orders, :created_by, :integer
    add_column :purchase_orders, :updated_by, :integer
  end
end
