class AddNominaIdToContractTypes < ActiveRecord::Migration
  def change
    add_column :contract_types, :nomina_id, :string

    add_index :contract_types, :nomina_id
  end
end
