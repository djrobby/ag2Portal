class AddMaximumToStocks < ActiveRecord::Migration
  def change
    add_column :stocks, :maximum, :decimal, :precision => 12, :scale => 4, :null => false, :default => '0'
  end
end
