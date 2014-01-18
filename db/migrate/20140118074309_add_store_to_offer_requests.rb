class AddStoreToOfferRequests < ActiveRecord::Migration
  def change
    add_column :offer_requests, :store_id, :integer
    add_column :offer_requests, :work_order_id, :integer
    add_column :offer_requests, :charge_account_id, :integer

    add_index :offer_requests, :store_id
    add_index :offer_requests, :work_order_id
    add_index :offer_requests, :charge_account_id
  end
end
