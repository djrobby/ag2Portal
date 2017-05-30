class CreateCurrencies < ActiveRecord::Migration
  def change
    create_table :currencies do |t|
      t.string :currency
      t.string :alphabetic_code, :limit => 3
      t.integer :numeric_code, :limit => 2
      t.integer :minor_unit, :limit => 1, :null => false, :default => 0

      t.timestamps
    end
    add_index :currencies, :alphabetic_code
    add_index :currencies, :numeric_code
    add_index :currencies, :currency
  end
end
