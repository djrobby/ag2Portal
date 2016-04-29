class CreateZoneNotifications < ActiveRecord::Migration
  def change
    create_table :zone_notifications do |t|
      t.references :zone
      t.references :notification
      t.references :user
      t.integer :role, :limit => 2

      t.timestamps
    end
    add_index :zone_notifications, :zone_id
    add_index :zone_notifications, :notification_id
    add_index :zone_notifications, :user_id
    add_index :zone_notifications, :role
  end
end
