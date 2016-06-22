class AddCreatedByToServicePointPurposes < ActiveRecord::Migration
  def change
    add_column :service_point_purposes, :created_by, :integer
    add_column :service_point_purposes, :updated_by, :integer
  end
end
