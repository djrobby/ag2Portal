class CreateCurrencyInstruments < ActiveRecord::Migration
  def change
    create_table :currency_instruments do |t|
      t.references :currency
      t.integer :type
      t.integer :value

      t.timestamps
    end
    add_index :currency_instruments, :currency_id
  end
end
