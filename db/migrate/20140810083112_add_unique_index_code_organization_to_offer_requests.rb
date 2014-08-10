class AddUniqueIndexCodeOrganizationToOfferRequests < ActiveRecord::Migration
  def change
    remove_index :offer_requests, :request_no    
    add_index :offer_requests, [:organization_id, :request_no], unique: true
  end
end
