class AddContractTemplateToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :water_supply_contract_template_id, :integer
    add_column :companies, :water_connection_contract_template_id, :integer

    add_index :companies, :water_supply_contract_template_id
    add_index :companies, :water_connection_contract_template_id
  end
end
