class CreateSupplierBankAccounts < ActiveRecord::Migration
  def change
    create_table :supplier_bank_accounts do |t|
      t.references :supplier
      t.references :bank_account_class
      t.references :country
      t.string :iban_dc
      t.references :bank
      t.references :bank_office
      t.string :ccc_dc
      t.string :account_no
      t.string :holder_fiscal_id
      t.string :holder_name
      t.date :starting_at
      t.date :ending_at

      t.timestamps
    end
    add_index :supplier_bank_accounts, :supplier_id
    add_index :supplier_bank_accounts, :bank_account_class_id
    add_index :supplier_bank_accounts, :country_id
    add_index :supplier_bank_accounts, :bank_id
    add_index :supplier_bank_accounts, :bank_office_id
    add_index :supplier_bank_accounts, :account_no
    add_index :supplier_bank_accounts, :holder_fiscal_id
    add_index :supplier_bank_accounts, :holder_name
    add_index :supplier_bank_accounts,
              [:supplier_id, :bank_account_class_id, :country_id, :iban_dc, :bank_id, :bank_office_id, :ccc_dc, :account_no],
              unique: true, name: 'index_supplier_bank_accounts_on_supplier_and_class_and_no'
  end
end
