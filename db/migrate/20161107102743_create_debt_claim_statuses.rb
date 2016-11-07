class CreateDebtClaimStatuses < ActiveRecord::Migration
  def change
    create_table :debt_claim_statuses do |t|
      t.string :name
      t.integer :action

      t.timestamps
    end
    add_index :debt_claim_statuses, :name
    add_index :debt_claim_statuses, :action
  end
end
