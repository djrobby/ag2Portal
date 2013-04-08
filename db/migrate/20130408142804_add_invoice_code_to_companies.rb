class AddInvoiceCodeToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :invoice_code, :string
    add_column :companies, :invoice_header, :string
    add_column :companies, :invoice_footer, :string
    add_column :companies, :invoice_left_margin, :string

    add_index :companies, :invoice_code
  end
end
