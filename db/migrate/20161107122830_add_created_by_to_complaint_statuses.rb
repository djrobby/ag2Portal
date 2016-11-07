class AddCreatedByToComplaintStatuses < ActiveRecord::Migration
  def change
    add_column :complaint_statuses, :created_by, :integer
    add_column :complaint_statuses, :updated_by, :integer
  end
end
