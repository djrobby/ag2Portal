class CreateInvoiceTaxes < ActiveRecord::Migration
  def change
    create_table :invoice_taxes do |t|
      t.references :invoice                                                     # invoice.id
      t.references :tax_type                                                    # tax_id
      t.string :description, limit: 100                                         # description
      t.decimal :tax, precision: 6, scale: 2, null: false, default: 0           # tax
      t.decimal :taxable, precision: 13, scale: 4, null: false, default: 0      # sum_total
      t.decimal :tax_amount, precision: 13, scale: 4, null: false, default: 0   # tax_total
      t.integer :items_qty, limit: 3, null: false, default: 0                   # t[1].count

      t.timestamps
    end
    add_index :invoice_taxes, :invoice_id
    add_index :invoice_taxes, :tax_type_id
  end
end
