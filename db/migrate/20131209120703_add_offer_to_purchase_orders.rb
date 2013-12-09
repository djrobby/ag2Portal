class AddOfferToPurchaseOrders < ActiveRecord::Migration
  def change
    add_column :purchase_orders, :offer_id, :integer
    add_index :purchase_orders, :offer_id
  end
end
