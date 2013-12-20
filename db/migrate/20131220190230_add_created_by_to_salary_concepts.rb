class AddCreatedByToSalaryConcepts < ActiveRecord::Migration
  def change
    add_column :salary_concepts, :created_by, :integer
    add_column :salary_concepts, :updated_by, :integer
  end
end
