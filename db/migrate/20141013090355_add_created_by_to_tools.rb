class AddCreatedByToTools < ActiveRecord::Migration
  def change
    add_column :tools, :created_by, :integer
    add_column :tools, :updated_by, :integer
  end
end
