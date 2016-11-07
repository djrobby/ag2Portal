class AddCreatedByToDebtClaimPhases < ActiveRecord::Migration
  def change
    add_column :debt_claim_phases, :created_by, :integer
    add_column :debt_claim_phases, :updated_by, :integer
  end
end
