class CreateProductCompanyPrices < ActiveRecord::Migration
  def change
    create_table :product_company_prices do |t|
      t.references :product
      t.references :company
      t.decimal :last_price, :precision => 12, :scale => 4, :null => false, :default => '0'
      t.decimal :average_price, :precision => 12, :scale => 4, :null => false, :default => '0'

      t.timestamps
    end
    add_index :product_company_prices, :product_id
    add_index :product_company_prices, :company_id
    add_index :product_company_prices, [ :product_id, :company_id ], unique: true, name: 'index_product_company_prices_on_product_and_company'
  end
end
