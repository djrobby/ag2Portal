class ChangeValueInCurrencyInstruments < ActiveRecord::Migration
  def change
    change_column :currency_instruments, :value, :decimal, precision: 14, scale: 6, null: false, default: 0
  end
end
