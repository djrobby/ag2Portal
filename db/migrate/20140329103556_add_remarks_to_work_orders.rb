class AddRemarksToWorkOrders < ActiveRecord::Migration
  def change
    add_column :work_orders, :remarks, :string
  end
end
