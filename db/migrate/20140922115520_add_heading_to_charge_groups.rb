class AddHeadingToChargeGroups < ActiveRecord::Migration
  def change
    add_column :charge_groups, :budget_heading_id, :integer
    add_index :charge_groups, :budget_heading_id
  end
end
