class CreateCurrencyInstruments < ActiveRecord::Migration
  def change
    create_table :currency_instruments do |t|
      t.references :currency
      t.integer :type, :limit => 1, :null => false, :default => 1
      t.integer :value, :null => false, :default => 0

      t.timestamps
    end
    add_index :currency_instruments, :currency_id
    add_index :currency_instruments, :type
  end
end
