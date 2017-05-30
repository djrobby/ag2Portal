class RenameTypeInCurrencyInstruments < ActiveRecord::Migration
  def change
    remove_index :currency_instruments, :type

    rename_column :currency_instruments, :type, :type_i

    add_index :currency_instruments, :type_i
  end
end
