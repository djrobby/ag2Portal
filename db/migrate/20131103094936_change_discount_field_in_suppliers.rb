class ChangeDiscountFieldInSuppliers < ActiveRecord::Migration
  def change
    change_column :suppliers, :discount_rate, :decimal, :precision => 6, :scale => 2, :null => false, :default => '0'
  end
end
