class CreateComplaintStatuses < ActiveRecord::Migration
  def change
    create_table :complaint_statuses do |t|
      t.string :name
      t.integer :action, limit: 1, null: false, default: '1'

      t.timestamps
    end
    add_index :complaint_statuses, :name
    add_index :complaint_statuses, :action
  end
end
