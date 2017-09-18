class AddItemsCountToDebtClaims < ActiveRecord::Migration
  def self.up
    add_column :debt_claims, :debt_claim_items_count, :integer, :default => 0

    DebtClaim.reset_column_information
    DebtClaim.find_each do |p|
      DebtClaim.reset_counters p.id, :debt_claim_items
    end
  end

  def self.down
    remove_column :debt_claims, :debt_claim_items_count
  end
end
