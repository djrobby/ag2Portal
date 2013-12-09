class AddCreatedByToOfferRequests < ActiveRecord::Migration
  def change
    add_column :offer_requests, :created_by, :integer
    add_column :offer_requests, :updated_by, :integer
  end
end
