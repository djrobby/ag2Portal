class AddTotalsToDebtClaims < ActiveRecord::Migration
  def change
    add_column :debt_claims, :totals, :decimal, :precision => 13, :scale => 4, :null => false, :default => 0
  end
end
