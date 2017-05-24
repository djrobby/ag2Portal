class AddPaidToCashDeskClosing < ActiveRecord::Migration
  def change
    add_column :cash_desk_closings, :amount_paid, :decimal, :precision => 13, :scale => 4, :null => false, :default => 0
    add_column :cash_desk_closings, :invoices_paid, :integer, null: false, default: 0
    change_column :cash_desk_closings, :invoices_collected, :integer, null: false, default: 0
  end
end
