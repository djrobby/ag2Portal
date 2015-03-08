class AddOrderAuthorizationToProductFamilies < ActiveRecord::Migration
  def change
    add_column :product_families, :order_authorization, :boolean
  end
end
