class AddCreatedByToProductTypes < ActiveRecord::Migration
  def change
    add_column :product_types, :created_by, :integer
    add_column :product_types, :updated_by, :integer
  end
end
