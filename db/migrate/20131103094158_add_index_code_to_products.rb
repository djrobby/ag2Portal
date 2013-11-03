class AddIndexCodeToProducts < ActiveRecord::Migration
  def change
    add_index :products, :product_code
    add_index :products, :main_description
    add_index :products, :aux_description
    add_index :products, :active
  end
end
