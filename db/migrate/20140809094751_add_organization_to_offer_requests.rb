class AddOrganizationToOfferRequests < ActiveRecord::Migration
  def change
    add_column :offer_requests, :organization_id, :integer
  end
end
