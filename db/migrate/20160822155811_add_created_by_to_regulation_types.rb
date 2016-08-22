class AddCreatedByToRegulationTypes < ActiveRecord::Migration
  def change
    add_column :regulation_types, :created_by, :integer
    add_column :regulation_types, :updated_by, :integer
  end
end
