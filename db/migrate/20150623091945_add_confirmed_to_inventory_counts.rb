class AddConfirmedToInventoryCounts < ActiveRecord::Migration
  def change
    add_column :inventory_counts, :confirmed, :boolean
  end
end
