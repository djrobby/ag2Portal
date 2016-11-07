class AddCreatedByToComplaintClasses < ActiveRecord::Migration
  def change
    add_column :complaint_classes, :created_by, :integer
    add_column :complaint_classes, :updated_by, :integer
  end
end
