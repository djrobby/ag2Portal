class CreateContractTemplates < ActiveRecord::Migration
  def change
    create_table :contract_templates do |t|
      t.string :name
      t.integer :for_contract, limit: 2, null: false, default: 0
      t.references :organization
      t.references :country
      t.references :region
      t.references :province
      t.references :town

      t.timestamps
    end
    add_index :contract_templates, :organization_id
    add_index :contract_templates, :country_id
    add_index :contract_templates, :region_id
    add_index :contract_templates, :province_id
    add_index :contract_templates, :town_id
    add_index :contract_templates, :name
  end
end
