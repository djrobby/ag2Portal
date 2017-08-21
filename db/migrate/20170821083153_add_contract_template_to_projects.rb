class AddContractTemplateToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :water_supply_contract_template_id, :integer
    add_column :projects, :water_connection_contract_template_id, :integer

    add_index :projects, :water_supply_contract_template_id
    add_index :projects, :water_connection_contract_template_id
  end
end
