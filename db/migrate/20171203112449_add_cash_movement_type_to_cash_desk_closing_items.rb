class AddCashMovementTypeToCashDeskClosingItems < ActiveRecord::Migration
  def change
    add_column :cash_desk_closing_items, :cash_movement_type_id, :integer

    add_index :cash_desk_closing_items, :cash_movement_type_id
  end
end
