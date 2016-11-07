class AddCreatedByToDebtClaimItems < ActiveRecord::Migration
  def change
    add_column :debt_claim_items, :created_by, :integer
    add_column :debt_claim_items, :updated_by, :integer
  end
end
