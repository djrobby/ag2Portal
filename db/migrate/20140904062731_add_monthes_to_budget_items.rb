class AddMonthesToBudgetItems < ActiveRecord::Migration
  def change
    add_column :budget_items, :month_01, :decimal, :precision => 13, :scale => 4, :null => false, :default => '0'
    add_column :budget_items, :month_02, :decimal, :precision => 13, :scale => 4, :null => false, :default => '0'
    add_column :budget_items, :month_03, :decimal, :precision => 13, :scale => 4, :null => false, :default => '0'
    add_column :budget_items, :month_04, :decimal, :precision => 13, :scale => 4, :null => false, :default => '0'
    add_column :budget_items, :month_05, :decimal, :precision => 13, :scale => 4, :null => false, :default => '0'
    add_column :budget_items, :month_06, :decimal, :precision => 13, :scale => 4, :null => false, :default => '0'
    add_column :budget_items, :month_07, :decimal, :precision => 13, :scale => 4, :null => false, :default => '0'
    add_column :budget_items, :month_08, :decimal, :precision => 13, :scale => 4, :null => false, :default => '0'
    add_column :budget_items, :month_09, :decimal, :precision => 13, :scale => 4, :null => false, :default => '0'
    add_column :budget_items, :month_10, :decimal, :precision => 13, :scale => 4, :null => false, :default => '0'
    add_column :budget_items, :month_11, :decimal, :precision => 13, :scale => 4, :null => false, :default => '0'
    add_column :budget_items, :month_12, :decimal, :precision => 13, :scale => 4, :null => false, :default => '0'
  end
end
