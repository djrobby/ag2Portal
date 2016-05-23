class AddChargeAccountToWorkOrderTypes < ActiveRecord::Migration
  def change
    add_column :work_order_types, :charge_account_id, :integer

    add_index :work_order_types, :charge_account_id
  end
end
