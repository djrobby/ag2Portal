class AddOvertimeToOffices < ActiveRecord::Migration
  def change
    add_column :offices, :overtime_pct, :decimal, :precision => 6, :scale => 2, :null => false, :default => '0'
  end
end
