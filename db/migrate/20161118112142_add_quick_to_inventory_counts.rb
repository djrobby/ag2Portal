class AddQuickToInventoryCounts < ActiveRecord::Migration
  def change
    add_column :inventory_counts, :quick, :boolean, :default => false
  end
end
