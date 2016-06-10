class AddCreatedByToReadingRoutes < ActiveRecord::Migration
  def change
    add_column :reading_routes, :created_by, :integer
    add_column :reading_routes, :updated_by, :integer
  end
end
