class AddCreatedByToSupplierLedgerAccounts < ActiveRecord::Migration
  def change
    add_column :supplier_ledger_accounts, :created_by, :integer
    add_column :supplier_ledger_accounts, :updated_by, :integer
  end
end
