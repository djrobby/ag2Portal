class AddOrganizationCompanyToDepartments < ActiveRecord::Migration
  def change
    add_column :departments, :organization_id, :integer
    add_column :departments, :company_id, :integer
    add_column :departments, :worker_id, :integer

    add_index :departments, :organization_id
    add_index :departments, :company_id
    add_index :departments, :worker_id
  end
end
