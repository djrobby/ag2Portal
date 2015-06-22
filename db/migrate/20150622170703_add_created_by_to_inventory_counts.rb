class AddCreatedByToInventoryCounts < ActiveRecord::Migration
  def change
    add_column :inventory_counts, :created_by, :integer
    add_column :inventory_counts, :updated_by, :integer
  end
end
