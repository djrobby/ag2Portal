class AddCreatedByToServicePointTypes < ActiveRecord::Migration
  def change
    add_column :service_point_types, :created_by, :integer
    add_column :service_point_types, :updated_by, :integer
  end
end
