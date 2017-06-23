class AddVoidCodeToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :void_invoice_code, :string
    add_column :companies, :void_commercial_bill_code, :string
    add_column :companies, :ledger_account_app_code, :string

    add_index :companies, :void_invoice_code
    add_index :companies, :void_commercial_bill_code
    add_index :companies, :ledger_account_app_code
  end
end
