class CreatePreInvoices < ActiveRecord::Migration
  def change
    create_table :pre_invoices do |t|
      t.string :invoice_no
      t.date :invoice_date
      t.references :pre_bill
      t.references :invoice_type
      t.references :invoice_operation
      t.references :invoice_status
      t.references :billing_period
      t.references :reading_1
      t.references :reading_2
      t.integer :consumption
      t.integer :consumption_real
      t.integer :consumption_estimated
      t.integer :consumption_other
      t.references :tariff_scheme
      t.references :biller
      t.decimal :discount_pct, :precision => 6, :scale => 2, :null => false, :default => '0'
      t.decimal :exemption, :precision => 12, :scale => 4, :null => false, :default => '0'
      t.references :charge_account
      t.references :invoice
      t.timestamp :confirmation_date

      t.timestamps
    end
    add_index :pre_invoices, :pre_bill_id
    add_index :pre_invoices, :invoice_type_id
    add_index :pre_invoices, :invoice_operation_id
    add_index :pre_invoices, :invoice_status_id
    add_index :pre_invoices, :billing_period_id
    add_index :pre_invoices, :reading_1_id
    add_index :pre_invoices, :reading_2_id
    add_index :pre_invoices, :tariff_scheme_id
    add_index :pre_invoices, :biller_id
    add_index :pre_invoices, :charge_account_id
  end
end
