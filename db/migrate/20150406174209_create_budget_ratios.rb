class CreateBudgetRatios < ActiveRecord::Migration
  def change
    create_table :budget_ratios do |t|
      t.references :budget
      t.references :ratio
      t.decimal :amount, :precision => 13, :scale => 4, :null => false, :default => '0'
      t.decimal :month_01, :precision => 13, :scale => 4, :null => false, :default => '0'
      t.decimal :month_02, :precision => 13, :scale => 4, :null => false, :default => '0'
      t.decimal :month_03, :precision => 13, :scale => 4, :null => false, :default => '0'
      t.decimal :month_04, :precision => 13, :scale => 4, :null => false, :default => '0'
      t.decimal :month_05, :precision => 13, :scale => 4, :null => false, :default => '0'
      t.decimal :month_06, :precision => 13, :scale => 4, :null => false, :default => '0'
      t.decimal :month_07, :precision => 13, :scale => 4, :null => false, :default => '0'
      t.decimal :month_08, :precision => 13, :scale => 4, :null => false, :default => '0'
      t.decimal :month_09, :precision => 13, :scale => 4, :null => false, :default => '0'
      t.decimal :month_10, :precision => 13, :scale => 4, :null => false, :default => '0'
      t.decimal :month_11, :precision => 13, :scale => 4, :null => false, :default => '0'
      t.decimal :month_12, :precision => 13, :scale => 4, :null => false, :default => '0'

      t.timestamps
    end
    add_index :budget_ratios, :budget_id
    add_index :budget_ratios, :ratio_id
  end
end
