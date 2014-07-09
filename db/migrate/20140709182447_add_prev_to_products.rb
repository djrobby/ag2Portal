class AddPrevToProducts < ActiveRecord::Migration
  def change
    add_column :products, :prev_last_price, :decimal, :precision => 12, :scale => 4, :null => false, :default => '0'
  end
end
