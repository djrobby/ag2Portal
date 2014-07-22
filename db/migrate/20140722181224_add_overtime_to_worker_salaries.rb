class AddOvertimeToWorkerSalaries < ActiveRecord::Migration
  def change
    add_column :worker_salaries, :overtime, :decimal, :precision => 12, :scale => 4, :null => false, :default => '0'
  end
end
