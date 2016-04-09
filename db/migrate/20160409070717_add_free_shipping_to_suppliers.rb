class AddFreeShippingToSuppliers < ActiveRecord::Migration
  def change
    add_column :suppliers, :free_shipping_sum, :decimal, :precision => 13, :scale => 4, :null => false, :default => '0'
  end
end
