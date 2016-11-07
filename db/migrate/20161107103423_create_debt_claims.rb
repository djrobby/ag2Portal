class CreateDebtClaims < ActiveRecord::Migration
  def change
    create_table :debt_claims do |t|
      t.references :project
      t.string :claim_no
      t.references :debt_claim_phase
      t.date :closed_at

      t.timestamps
    end
    add_index :debt_claims, :project_id
    add_index :debt_claims, :debt_claim_phase_id
    add_index :debt_claims, :claim_no
  end
end
