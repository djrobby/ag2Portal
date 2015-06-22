class AddCreatedByToInventoryCountTypes < ActiveRecord::Migration
  def change
    add_column :inventory_count_types, :created_by, :integer
    add_column :inventory_count_types, :updated_by, :integer
  end
end
