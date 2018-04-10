class CreateSepaReturnCodes < ActiveRecord::Migration
  def change
    create_table :sepa_return_codes do |t|
      t.string :code, limit: 10
      t.string :name, limit: 100

      t.timestamps
    end
    add_index :sepa_return_codes, :code
  end
end
