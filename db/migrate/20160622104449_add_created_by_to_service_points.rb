class AddCreatedByToServicePoints < ActiveRecord::Migration
  def change
    add_column :service_points, :created_by, :integer
    add_column :service_points, :updated_by, :integer
  end
end
