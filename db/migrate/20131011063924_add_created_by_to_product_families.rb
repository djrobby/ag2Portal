class AddCreatedByToProductFamilies < ActiveRecord::Migration
  def change
    add_column :product_families, :created_by, :integer
    add_column :product_families, :updated_by, :integer
  end
end
