class CreateClientPayments < ActiveRecord::Migration
  def change
    create_table :client_payments do |t|
      t.string :receipt_no
      t.integer :payment_type
      t.references :bill
      t.references :invoice
      t.references :payment_method
      t.references :client
      t.references :subscriber
      t.date :payment_date
      t.timestamp :confirmation_date
      t.decimal :amount, :precision => 12, :scale => 4, :null => false, :default => '0'
      t.references :instalment
      t.decimal :surcharge, :precision => 12, :scale => 4, :null => false, :default => '0'
      t.references :client_bank_account
      t.references :charge_account

      t.timestamps
    end
    add_index :client_payments, :receipt_no
    add_index :client_payments, :payment_type
    add_index :client_payments, :bill_id
    add_index :client_payments, :invoice_id
    add_index :client_payments, :payment_method_id
    add_index :client_payments, :client_id
    add_index :client_payments, :subscriber_id
    add_index :client_payments, :payment_date
    add_index :client_payments, :confirmation_date
    add_index :client_payments, :instalment_id
    add_index :client_payments, :client_bank_account_id
    add_index :client_payments, :charge_account_id
  end
end
