class AddOrganizationToProfessionalGroups < ActiveRecord::Migration
  def change
    add_column :professional_groups, :organization_id, :integer
  end
end
