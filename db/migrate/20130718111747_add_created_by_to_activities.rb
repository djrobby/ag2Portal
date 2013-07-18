class AddCreatedByToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :created_by, :string
    add_column :activities, :updated_by, :string
  end
end
