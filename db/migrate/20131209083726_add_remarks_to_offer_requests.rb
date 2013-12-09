class AddRemarksToOfferRequests < ActiveRecord::Migration
  def change
    add_column :offer_requests, :remarks, :string
  end
end
