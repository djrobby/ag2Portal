class RenameTypeInCashDeskClosingItems < ActiveRecord::Migration
  def change
    rename_column :cash_desk_closing_items, :type, :type_i

    add_index :cash_desk_closing_items, :type_i
  end
end
