class AddTotalsToWorkOrders < ActiveRecord::Migration
  def self.up
    add_column :work_orders, :totals, :decimal, :precision => 13, :scale => 4, :null => false, :default => 0
    add_column :work_orders, :this_costs, :decimal, :precision => 13, :scale => 4, :null => false, :default => 0
    add_column :work_orders, :with_suborder_costs, :decimal, :precision => 13, :scale => 4, :null => false, :default => 0

    WorkOrder.find_each do |p|
      p.update_column(:totals, p.total)
      p.update_column(:this_costs, p.this_total_costs)
      p.update_column(:with_suborder_costs, p.total_costs)
    end
  end

  def self.down
    remove_column :work_orders, :totals
  end
end
