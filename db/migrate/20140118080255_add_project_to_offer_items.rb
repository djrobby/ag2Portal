class AddProjectToOfferItems < ActiveRecord::Migration
  def change
    add_column :offer_items, :project_id, :integer
    add_column :offer_items, :store_id, :integer
    add_column :offer_items, :work_order_id, :integer
    add_column :offer_items, :charge_account_id, :integer

    add_index :offer_items, :project_id
    add_index :offer_items, :store_id
    add_index :offer_items, :work_order_id
    add_index :offer_items, :charge_account_id
  end
end
