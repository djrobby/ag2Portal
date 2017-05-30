class CreateCashDeskClosingInstruments < ActiveRecord::Migration
  def change
    create_table :cash_desk_closing_instruments do |t|
      t.references :cash_desk_closing
      t.references :currency_instrument
      t.decimal :amount, :precision => 13, :scale => 4, :null => false, :default => 0

      t.timestamps
    end
    add_index :cash_desk_closing_instruments, :cash_desk_closing_id
    add_index :cash_desk_closing_instruments, :currency_instrument_id
  end
end
