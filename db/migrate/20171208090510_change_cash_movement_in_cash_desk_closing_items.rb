class ChangeCashMovementInCashDeskClosingItems < ActiveRecord::Migration
  def change
    remove_index :cash_desk_closing_items, :cash_movement_type_id
    remove_column :cash_desk_closing_items, :cash_movement_type_id
    add_column :cash_desk_closing_items, :cash_movement_id, :integer
    add_index :cash_desk_closing_items, :cash_movement_id
  end
end
