class AddCreatedByToRatioGroups < ActiveRecord::Migration
  def change
    add_column :ratio_groups, :created_by, :integer
    add_column :ratio_groups, :updated_by, :integer
  end
end
