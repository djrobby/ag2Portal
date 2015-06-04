class AddCreatedByToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :created_by, :integer
    add_column :notifications, :updated_by, :integer
  end
end
