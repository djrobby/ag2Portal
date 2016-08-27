class CreateInvoiceOperations < ActiveRecord::Migration
  def change
    create_table :invoice_operations do |t|
      t.string :name

      t.timestamps
    end
  end
end
