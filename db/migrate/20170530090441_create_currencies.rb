class CreateCurrencies < ActiveRecord::Migration
  def change
    create_table :currencies do |t|
      t.string :currency
      t.string :alphabetic_code
      t.integer :numeric_code
      t.integer :minor_unit

      t.timestamps
    end
  end
end
