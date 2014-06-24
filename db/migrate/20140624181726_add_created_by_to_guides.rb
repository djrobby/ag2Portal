class AddCreatedByToGuides < ActiveRecord::Migration
  def change
    add_column :guides, :created_by, :integer
    add_column :guides, :updated_by, :integer
  end
end
