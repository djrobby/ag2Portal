class AddOrganizationToCollectiveAgreements < ActiveRecord::Migration
  def change
    add_column :collective_agreements, :organization_id, :integer
  end
end
