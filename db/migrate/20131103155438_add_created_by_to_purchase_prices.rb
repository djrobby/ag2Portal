class AddCreatedByToPurchasePrices < ActiveRecord::Migration
  def change
    add_column :purchase_prices, :created_by, :integer
    add_column :purchase_prices, :updated_by, :integer
  end
end
