class AddOrganizationToSalaryConcepts < ActiveRecord::Migration
  def change
    add_column :salary_concepts, :organization_id, :integer
    add_index :salary_concepts, :organization_id
  end
end
