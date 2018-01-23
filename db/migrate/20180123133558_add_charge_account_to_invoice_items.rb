class AddChargeAccountToInvoiceItems < ActiveRecord::Migration
  def change
    add_column :invoice_items, :charge_account_id, :integer
    add_index :invoice_items, :charge_account_id
  end
end
