class AddCreatedByToOrderStatuses < ActiveRecord::Migration
  def change
    add_column :order_statuses, :created_by, :integer
    add_column :order_statuses, :updated_by, :integer
  end
end
