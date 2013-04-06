class CreateContractTypes < ActiveRecord::Migration
  def change
    create_table :contract_types do |t|
      t.string :name
      t.string :ct_code

      t.timestamps
    end
    add_index :contract_types, :ct_code
  end
end
