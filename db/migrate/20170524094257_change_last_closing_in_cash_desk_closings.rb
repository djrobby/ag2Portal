class ChangeLastClosingInCashDeskClosings < ActiveRecord::Migration
  def change
    remove_column :cash_desk_closings, :last_closing
    add_column :cash_desk_closings, :last_closing_id, :integer

    add_index :cash_desk_closings, :last_closing_id
  end
end
