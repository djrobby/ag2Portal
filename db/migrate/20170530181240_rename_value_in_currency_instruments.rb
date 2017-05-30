class RenameValueInCurrencyInstruments < ActiveRecord::Migration
  def change
    rename_column :currency_instruments, :value, :value_i
  end
end
