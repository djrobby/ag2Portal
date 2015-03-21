class CreateLedgerAccounts < ActiveRecord::Migration
  def change
    create_table :ledger_accounts do |t|
      t.string :code
      t.string :name
      t.references :accounting_group
      t.references :project
      t.references :organization

      t.timestamps
    end
    add_index :ledger_accounts, :accounting_group_id
    add_index :ledger_accounts, :project_id
    add_index :ledger_accounts, :organization_id
    add_index :ledger_accounts, :code
    add_index :ledger_accounts, [:organization_id, :code], unique: true, name: 'index_ledger_accounts_on_organization_and_code'
  end
end
