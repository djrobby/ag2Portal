class AddIndexManufacturerPCodeToProducts < ActiveRecord::Migration
  def change
    add_index :products, :manufacturer_p_code
  end
end
