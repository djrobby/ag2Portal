class AddCreatedByToInstalmentPlans < ActiveRecord::Migration
  def change
    add_column :instalment_plans, :created_by, :integer
    add_column :instalment_plans, :updated_by, :integer
  end
end
