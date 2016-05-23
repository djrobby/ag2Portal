class AddPoOrAffectedToWorkOrders < ActiveRecord::Migration
  def change
    add_column :work_orders, :por_affected, :boolean
  end
end
