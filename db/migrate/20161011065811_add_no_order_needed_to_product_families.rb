class AddNoOrderNeededToProductFamilies < ActiveRecord::Migration
  def change
    add_column :product_families, :no_order_needed, :boolean
  end
end
