class AddCreatedByToChargeGroups < ActiveRecord::Migration
  def change
    add_column :charge_groups, :created_by, :integer
    add_column :charge_groups, :updated_by, :integer
  end
end
