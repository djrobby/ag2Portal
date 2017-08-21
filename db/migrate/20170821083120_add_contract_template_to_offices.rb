class AddContractTemplateToOffices < ActiveRecord::Migration
  def change
    add_column :offices, :water_supply_contract_template_id, :integer
    add_column :offices, :water_connection_contract_template_id, :integer

    add_index :offices, :water_supply_contract_template_id
    add_index :offices, :water_connection_contract_template_id
  end
end
