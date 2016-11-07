class ChangeActionInDebtClaimStatuses < ActiveRecord::Migration
  def change
    change_column :debt_claim_statuses, :action, :integer, :limit => 1, :null => false, :default => '1'
  end
end
