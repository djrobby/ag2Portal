class AddDescriptionToWorkOrders < ActiveRecord::Migration
  def change
    add_column :work_orders, :description, :string
  end
end
