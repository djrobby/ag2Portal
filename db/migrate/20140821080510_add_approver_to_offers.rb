class AddApproverToOffers < ActiveRecord::Migration
  def change
    add_column :offers, :approver_id, :integer
    add_column :offers, :approval_date, :timestamp
    add_index :offers, :approver_id
  end
end
