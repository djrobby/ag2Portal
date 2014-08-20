class AddCreatedByToSaleOfferItems < ActiveRecord::Migration
  def change
    add_column :sale_offer_items, :created_by, :integer
    add_column :sale_offer_items, :updated_by, :integer
  end
end
