class AddCreatedByToAreas < ActiveRecord::Migration
  def change
    add_column :areas, :created_by, :integer
    add_column :areas, :updated_by, :integer
  end
end
