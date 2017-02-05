class AddContractingRequestToSaleOffers < ActiveRecord::Migration
  def change
    add_column :sale_offers, :contracting_request_id, :integer

    add_index :sale_offers, :contracting_request_id
  end
end
