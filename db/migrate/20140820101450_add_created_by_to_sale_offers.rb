class AddCreatedByToSaleOffers < ActiveRecord::Migration
  def change
    add_column :sale_offers, :created_by, :integer
    add_column :sale_offers, :updated_by, :integer
  end
end
