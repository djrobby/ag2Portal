class AddSubtotalsToDebtClaims < ActiveRecord::Migration
  def self.up
    add_column :debt_claims, :subtotals, :decimal, :precision => 13, :scale => 4, :null => false, :default => 0
    add_column :debt_claims, :surcharges, :decimal, :precision => 13, :scale => 4, :null => false, :default => 0

    DebtClaim.find_each do |p|
      p.update_column(:subtotals, p.subtotal)
      p.update_column(:surcharges, p.surcharge)
    end
  end

  def self.down
    remove_column :debt_claims, :subtotals
    remove_column :debt_claims, :surcharges
  end
end
