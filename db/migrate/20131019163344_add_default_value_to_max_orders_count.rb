class AddDefaultValueToMaxOrdersCount < ActiveRecord::Migration
  def change
    change_column_default :suppliers, :max_orders_count, 0
    change_column_default :product_families, :max_orders_count, 0
  end
end
