class AddCreatedByToSuppliersActivities < ActiveRecord::Migration
  def change
    add_column :suppliers_activities, :created_by, :string
    add_column :suppliers_activities, :updated_by, :string
  end
end
