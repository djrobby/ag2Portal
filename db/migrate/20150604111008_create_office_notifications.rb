class CreateOfficeNotifications < ActiveRecord::Migration
  def change
    create_table :office_notifications do |t|
      t.references :office
      t.references :notification
      t.references :user
      t.integer :role, :limit => 2

      t.timestamps
    end
    add_index :office_notifications, :office_id
    add_index :office_notifications, :notification_id
    add_index :office_notifications, :user_id
    add_index :office_notifications, :role
  end
end
