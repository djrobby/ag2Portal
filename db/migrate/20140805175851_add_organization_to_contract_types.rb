class AddOrganizationToContractTypes < ActiveRecord::Migration
  def change
    add_column :contract_types, :organization_id, :integer
  end
end
