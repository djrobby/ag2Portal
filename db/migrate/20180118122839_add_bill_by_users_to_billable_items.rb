class AddBillByUsersToBillableItems < ActiveRecord::Migration
  def change
    add_column :billable_items, :bill_by_users, :boolean, null: false, default: false
  end
end
