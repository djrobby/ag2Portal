class AddCodeIndexToOfferRequests < ActiveRecord::Migration
  def change
    add_index :offer_requests, :organization_id    
    add_index :offer_requests, :request_no    
  end
end
