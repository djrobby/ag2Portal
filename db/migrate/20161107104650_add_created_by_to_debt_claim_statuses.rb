class AddCreatedByToDebtClaimStatuses < ActiveRecord::Migration
  def change
    add_column :debt_claim_statuses, :created_by, :integer
    add_column :debt_claim_statuses, :updated_by, :integer
  end
end
