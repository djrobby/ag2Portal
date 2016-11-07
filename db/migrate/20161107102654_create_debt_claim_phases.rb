class CreateDebtClaimPhases < ActiveRecord::Migration
  def change
    create_table :debt_claim_phases do |t|
      t.string :name
      t.decimal :surcharge_pct

      t.timestamps
    end
    add_index :debt_claim_phases, :name
  end
end
