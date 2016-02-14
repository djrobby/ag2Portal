class AddStoreAddressToPurchaseOrders < ActiveRecord::Migration
  def change
    add_column :purchase_orders, :store_address_1, :string
    add_column :purchase_orders, :store_address_2, :string
    add_column :purchase_orders, :store_phones, :string
  end
end
