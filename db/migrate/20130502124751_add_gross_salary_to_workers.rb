class AddGrossSalaryToWorkers < ActiveRecord::Migration
  def change
    add_column :workers, :gross_salary, :decimal, :precision => 12, :scale => 4, :null => false, :default => '0'
    add_column :workers, :variable_salary, :decimal, :precision => 12, :scale => 4, :null => false, :default => '0'
  end
end
