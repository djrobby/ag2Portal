class AddCreatedByToSaleOfferStatuses < ActiveRecord::Migration
  def change
    add_column :sale_offer_statuses, :created_by, :integer
    add_column :sale_offer_statuses, :updated_by, :integer
  end
end
