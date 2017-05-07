class AddOrganizationToInstalmentPlans < ActiveRecord::Migration
  def change
    add_column :instalment_plans, :organization_id, :integer

    add_index :instalment_plans, :organization_id
  end
end
