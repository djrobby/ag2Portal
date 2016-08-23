class AddInvoiceToReadings < ActiveRecord::Migration
  def change
    add_column :readings, :invoice_id, :integer
    add_column :readings, :reading_index_1, :integer
    add_column :readings, :reading_index_2, :integer

    add_index :readings, :invoice_id
  end
end
