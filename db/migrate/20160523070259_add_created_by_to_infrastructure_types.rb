class AddCreatedByToInfrastructureTypes < ActiveRecord::Migration
  def change
    add_column :infrastructure_types, :created_by, :integer
    add_column :infrastructure_types, :updated_by, :integer
  end
end
