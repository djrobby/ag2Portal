class AddIsMeterToProductFamilies < ActiveRecord::Migration
  def change
    add_column :product_families, :is_meter, :boolean
  end
end
