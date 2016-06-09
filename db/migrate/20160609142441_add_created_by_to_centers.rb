class AddCreatedByToCenters < ActiveRecord::Migration
  def change
    add_column :centers, :created_by, :integer
    add_column :centers, :updated_by, :integer
  end
end
