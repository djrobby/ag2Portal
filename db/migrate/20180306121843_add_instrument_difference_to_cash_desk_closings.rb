class AddInstrumentDifferenceToCashDeskClosings < ActiveRecord::Migration
  def change
    add_column :cash_desk_closings, :instruments_difference, :decimal, :precision => 13, :scale => 4, :null => false, :default => 0
  end
end
