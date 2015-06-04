class ChangeActionInNotifications < ActiveRecord::Migration
  def change
    change_column :notifications, :action, :integer, :limit => 2
  end
end
