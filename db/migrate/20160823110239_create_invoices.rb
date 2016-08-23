class CreateInvoices < ActiveRecord::Migration
  def change
    create_table :invoices do |t|
      t.string :invoice_no
      t.date :invoice_date
      t.references :bill
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
      t.references :original_invoice
      t.references :charge_account

      t.timestamps
    end
    add_index :invoices, :bill_id
    add_index :invoices, :invoice_type_id
    add_index :invoices, :invoice_operation_id
    add_index :invoices, :invoice_status_id
    add_index :invoices, :billing_period_id
    add_index :invoices, :reading_1_id
    add_index :invoices, :reading_2_id
    add_index :invoices, :tariff_scheme_id
    add_index :invoices, :biller_id
    add_index :invoices, :original_invoice_id
    add_index :invoices, :charge_account_id
  end
end
