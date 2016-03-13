class AddCreatedByToMeterOwners < ActiveRecord::Migration
  def change
    add_column :meter_owners, :created_by, :integer
    add_column :meter_owners, :updated_by, :integer
  end
end
