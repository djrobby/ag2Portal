class AddInChargeToWorkOrders < ActiveRecord::Migration
  def change
    add_column :work_orders, :in_charge_id, :integer

    add_index :work_orders, :in_charge_id
  end
end
