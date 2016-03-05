class AddSupplierToProductCompanyPrices < ActiveRecord::Migration
  def change
    add_column :product_company_prices, :supplier_id, :integer
    add_column :product_company_prices, :prev_supplier_id, :integer

    add_index :product_company_prices, :supplier_id
  end
end
