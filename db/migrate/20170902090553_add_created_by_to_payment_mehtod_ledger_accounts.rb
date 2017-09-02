class AddCreatedByToPaymentMehtodLedgerAccounts < ActiveRecord::Migration
  def change
    add_column :payment_method_ledger_accounts, :created_by, :integer
    add_column :payment_method_ledger_accounts, :updated_by, :integer
  end
end
