class AddCreatedByToInventoryCountItems < ActiveRecord::Migration
  def change
    add_column :inventory_count_items, :created_by, :integer
    add_column :inventory_count_items, :updated_by, :integer
  end
end
