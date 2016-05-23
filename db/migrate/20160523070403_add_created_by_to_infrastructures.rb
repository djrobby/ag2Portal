class AddCreatedByToInfrastructures < ActiveRecord::Migration
  def change
    add_column :infrastructures, :created_by, :integer
    add_column :infrastructures, :updated_by, :integer
  end
end
