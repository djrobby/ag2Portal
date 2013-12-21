class CreateSupplierInvoices < ActiveRecord::Migration
  def change
    create_table :supplier_invoices do |t|
      t.string :invoice_no
      t.references :supplier
      t.references :payment_method
      t.date :invoice_date
      t.string :remarks
      t.decimal :discount_pct, :precision => 6, :scale => 2, :null => false, :default => '0'
      t.decimal :discount, :precision => 13, :scale => 4, :null => false, :default => '0'
      t.references :project
      t.references :work_order
      t.references :charge_account

      t.timestamps
    end
    add_index :supplier_invoices, :supplier_id
    add_index :supplier_invoices, :payment_method_id
    add_index :supplier_invoices, :project_id
    add_index :supplier_invoices, :work_order_id
    add_index :supplier_invoices, :charge_account_id
    add_index :supplier_invoices, :invoice_no
    add_index :supplier_invoices, :invoice_date
  end
end
