class AddLocationToWorkOrders < ActiveRecord::Migration
  def change
    add_column :work_orders, :location, :string
    add_column :work_orders, :pub_record, :string
  end
end
