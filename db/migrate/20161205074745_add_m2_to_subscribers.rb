class AddM2ToSubscribers < ActiveRecord::Migration
  def change
    add_column :subscribers, :m2, :decimal, :precision => 12, :scale => 4, :null => false, :default => '0'
    add_column :subscribers, :equiv_dwelling, :decimal, :precision => 12, :scale => 4, :null => false, :default => '0'
  end
end
