class AddApprovalDateToSaleOffers < ActiveRecord::Migration
  def change
    add_column :sale_offers, :approval_date, :timestamp
    add_column :sale_offers, :approver, :string
  end
end
