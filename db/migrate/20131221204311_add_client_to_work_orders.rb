class AddClientToWorkOrders < ActiveRecord::Migration
  def change
    add_column :work_orders, :client_id, :integer
    add_index :work_orders, :client_id
  end
end
