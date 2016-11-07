class AddCreatedByToFormalityTypes < ActiveRecord::Migration
  def change
    add_column :formality_types, :created_by, :integer
    add_column :formality_types, :updated_by, :integer
  end
end
