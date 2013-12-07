class CreateChargeAccounts < ActiveRecord::Migration
  def change
    create_table :charge_accounts do |t|
      t.string :name
      t.date :opened_at
      t.date :closed_at
      t.references :project
      t.string :ledger_account

      t.timestamps
    end
    add_index :charge_accounts, :project_id
    add_index :charge_accounts, :name
    add_index :charge_accounts, :ledger_account
  end
end
