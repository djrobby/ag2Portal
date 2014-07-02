class AddSaleOfferToDeliveryNotes < ActiveRecord::Migration
  def change
    add_column :delivery_notes, :sale_offer_id, :integer
    add_index :delivery_notes, :sale_offer_id
  end
end
