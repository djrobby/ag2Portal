class AddPaymentMethodToCashDeskClosingItems < ActiveRecord::Migration
  def change
    add_column :cash_desk_closing_items, :payment_method_id, :integer
    add_index :cash_desk_closing_items, :payment_method_id
  end
end
