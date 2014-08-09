class AddOrganizationToTechnicians < ActiveRecord::Migration
  def change
    add_column :technicians, :organization_id, :integer
  end
end
