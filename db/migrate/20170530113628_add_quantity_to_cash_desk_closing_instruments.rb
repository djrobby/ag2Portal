class AddQuantityToCashDeskClosingInstruments < ActiveRecord::Migration
  def change
    add_column :cash_desk_closing_instruments, :quantity, :integer, :limit => 2, :null => false, :default => 0
  end
end
