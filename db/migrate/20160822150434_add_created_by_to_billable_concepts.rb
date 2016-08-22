class AddCreatedByToBillableConcepts < ActiveRecord::Migration
  def change
    add_column :billable_concepts, :created_by, :integer
    add_column :billable_concepts, :updated_by, :integer
  end
end
