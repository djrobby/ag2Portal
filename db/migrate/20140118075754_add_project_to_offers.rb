class AddProjectToOffers < ActiveRecord::Migration
  def change
    add_column :offers, :project_id, :integer
    add_column :offers, :store_id, :integer
    add_column :offers, :work_order_id, :integer
    add_column :offers, :charge_account_id, :integer

    add_index :offers, :project_id
    add_index :offers, :store_id
    add_index :offers, :work_order_id
    add_index :offers, :charge_account_id
  end
end
