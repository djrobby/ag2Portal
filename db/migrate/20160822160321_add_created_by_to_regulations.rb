class AddCreatedByToRegulations < ActiveRecord::Migration
  def change
    add_column :regulations, :created_by, :integer
    add_column :regulations, :updated_by, :integer
  end
end
