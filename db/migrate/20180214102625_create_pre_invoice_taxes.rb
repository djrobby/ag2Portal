class CreatePreInvoiceTaxes < ActiveRecord::Migration
  def change
    create_table :pre_invoice_taxes do |t|
      t.references :pre_invoice                                                 # pre_invoice.id
      t.references :tax_type                                                    # tax_id
      t.string :description, limit: 100                                         # description
      t.decimal :tax, precision: 6, scale: 2, null: false, default: 0           # tax
      t.decimal :taxable, precision: 13, scale: 4, null: false, default: 0      # sum_total
      t.decimal :tax_amount, precision: 13, scale: 4, null: false, default: 0   # tax_total
      t.integer :items_qty, limit: 3, null: false, default: 0                   # t[1].count

      t.timestamps
    end
    add_index :pre_invoice_taxes, :pre_invoice_id
    add_index :pre_invoice_taxes, :tax_type_id
  end
end
