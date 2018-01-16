class AddBillByToBillableItems < ActiveRecord::Migration
  def change
    add_column :billable_items, :bill_by_endowments, :boolean, null: false, default: false
    add_column :billable_items, :bill_by_inhabitants, :boolean, null: false, default: false
  end
end
