class AddCreatedByToProductCompanyPrices < ActiveRecord::Migration
  def change
    add_column :product_company_prices, :created_by, :integer
    add_column :product_company_prices, :updated_by, :integer
  end
end
