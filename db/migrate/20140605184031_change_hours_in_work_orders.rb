class ChangeHoursInWorkOrders < ActiveRecord::Migration
  def change
    change_column :work_order_workers, :hours, :decimal, :precision => 9, :scale => 4, :null => false, :default => '0'
  end
end
