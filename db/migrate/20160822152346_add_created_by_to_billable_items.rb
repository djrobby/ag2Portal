class AddCreatedByToBillableItems < ActiveRecord::Migration
  def change
    add_column :billable_items, :created_by, :integer
    add_column :billable_items, :updated_by, :integer
  end
end
