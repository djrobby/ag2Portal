class AddHoursTypeToWorkOrders < ActiveRecord::Migration
  def change
    add_column :work_orders, :hours_type, :integer, :limit => 2, :null => false, :default => '0'
  end
end
