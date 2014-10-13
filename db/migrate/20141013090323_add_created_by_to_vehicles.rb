class AddCreatedByToVehicles < ActiveRecord::Migration
  def change
    add_column :vehicles, :created_by, :integer
    add_column :vehicles, :updated_by, :integer
  end
end
