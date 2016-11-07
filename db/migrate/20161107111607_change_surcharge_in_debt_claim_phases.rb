class ChangeSurchargeInDebtClaimPhases < ActiveRecord::Migration
  def change
    change_column :debt_claim_phases, :surcharge_pct, :decimal, :precision => 6, :scale => 2, :null => false, :default => '0'
  end
end
