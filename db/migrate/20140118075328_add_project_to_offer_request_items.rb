class AddProjectToOfferRequestItems < ActiveRecord::Migration
  def change
    add_column :offer_request_items, :project_id, :integer
    add_column :offer_request_items, :store_id, :integer
    add_column :offer_request_items, :work_order_id, :integer
    add_column :offer_request_items, :charge_account_id, :integer

    add_index :offer_request_items, :project_id
    add_index :offer_request_items, :store_id
    add_index :offer_request_items, :work_order_id
    add_index :offer_request_items, :charge_account_id
  end
end
