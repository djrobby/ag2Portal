class AddOvertimeToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :overtime_pct, :decimal, :precision => 6, :scale => 2, :null => false, :default => '0'
  end
end
