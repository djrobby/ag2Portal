class AddOtherToCashDeskClosing < ActiveRecord::Migration
  def change
    add_column :cash_desk_closings, :amount_others, :decimal, :precision => 13, :scale => 4, :null => false, :default => 0
    add_column :cash_desk_closings, :quantity_others, :integer, null: false, default: 0
  end
end
