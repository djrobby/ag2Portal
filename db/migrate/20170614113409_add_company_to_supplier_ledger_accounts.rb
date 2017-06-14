class AddCompanyToSupplierLedgerAccounts < ActiveRecord::Migration
  def change
    add_column :supplier_ledger_accounts, :company_id, :integer

    add_index :supplier_ledger_accounts, :company_id
  end
end
