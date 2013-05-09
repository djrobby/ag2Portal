class AddCreatedByToProfessionalGroups < ActiveRecord::Migration
  def change
    add_column :professional_groups, :created_by, :integer
    add_column :professional_groups, :updated_by, :integer
  end
end
