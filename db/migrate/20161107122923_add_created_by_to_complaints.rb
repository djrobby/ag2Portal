class AddCreatedByToComplaints < ActiveRecord::Migration
  def change
    add_column :complaints, :created_by, :integer
    add_column :complaints, :updated_by, :integer
  end
end
