class AddPetitionerAndMasterToWorkOrders < ActiveRecord::Migration
  def change
    add_column :work_orders, :petitioner, :string
    add_column :work_orders, :master_order_id, :integer

    add_index :work_orders, :master_order_id
  end
end
