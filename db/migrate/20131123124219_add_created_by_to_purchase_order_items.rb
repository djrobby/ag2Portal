class AddCreatedByToPurchaseOrderItems < ActiveRecord::Migration
  def change
    add_column :purchase_order_items, :created_by, :integer
    add_column :purchase_order_items, :updated_by, :integer
  end
end
