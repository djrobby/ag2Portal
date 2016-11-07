class CreateDebtClaimItems < ActiveRecord::Migration
  def change
    create_table :debt_claim_items do |t|
      t.references :debt_claim
      t.references :bill
      t.references :invoice
      t.references :debt_claim_status
      t.date :payday_limit

      t.timestamps
    end
    add_index :debt_claim_items, :debt_claim_id
    add_index :debt_claim_items, :bill_id
    add_index :debt_claim_items, :invoice_id
    add_index :debt_claim_items, :debt_claim_status_id
  end
end
