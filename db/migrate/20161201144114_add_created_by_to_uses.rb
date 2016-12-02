class AddCreatedByToUses < ActiveRecord::Migration
  def change
    add_column :uses, :created_by, :integer
    add_column :uses, :updated_by, :integer
  end
end
