class ChangeNumberFieldsInProducts < ActiveRecord::Migration
  def change
    change_column :products, :reference_price, :decimal, :precision => 12, :scale => 4, :null => false, :default => '0'
    change_column :products, :last_price, :decimal, :precision => 12, :scale => 4, :null => false, :default => '0'
    change_column :products, :average_price, :decimal, :precision => 12, :scale => 4, :null => false, :default => '0'
    change_column :products, :average_price, :decimal, :precision => 12, :scale => 4, :null => false, :default => '0'
    change_column :products, :markup, :decimal, :precision => 6, :scale => 2, :null => false, :default => '0'
    change_column :products, :warranty_time, :integer, :limit => 2, :null => false, :default => '0'
    change_column :products, :life_time, :integer, :limit => 2, :null => false, :default => '0'
  end
end
