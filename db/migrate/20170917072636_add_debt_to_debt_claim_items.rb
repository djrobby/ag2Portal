class AddDebtToDebtClaimItems < ActiveRecord::Migration
  def change
    add_column :debt_claim_items, :debt, :decimal, :precision => 12, :scale => 4, :null => false, :default => 0
  end
end
