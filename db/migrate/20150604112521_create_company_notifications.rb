class CreateCompanyNotifications < ActiveRecord::Migration
  def change
    create_table :company_notifications do |t|
      t.references :company
      t.references :notification
      t.references :user
      t.integer :role, :limit => 2

      t.timestamps
    end
    add_index :company_notifications, :company_id
    add_index :company_notifications, :notification_id
    add_index :company_notifications, :user_id
    add_index :company_notifications, :role
  end
end
