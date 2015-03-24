class AddCreatedByToAccountingGroups < ActiveRecord::Migration
  def change
    add_column :accounting_groups, :created_by, :integer
    add_column :accounting_groups, :updated_by, :integer
  end
end
