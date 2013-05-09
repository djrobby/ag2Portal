class AddCreatedByToTowns < ActiveRecord::Migration
  def change
    add_column :towns, :created_by, :integer
    add_column :towns, :updated_by, :integer
  end
end
