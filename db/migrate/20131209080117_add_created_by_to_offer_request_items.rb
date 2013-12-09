class AddCreatedByToOfferRequestItems < ActiveRecord::Migration
  def change
    add_column :offer_request_items, :created_by, :integer
    add_column :offer_request_items, :updated_by, :integer
  end
end
