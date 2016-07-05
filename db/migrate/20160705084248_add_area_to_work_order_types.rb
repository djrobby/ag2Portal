class AddAreaToWorkOrderTypes < ActiveRecord::Migration
  def change
    add_column :work_order_types, :work_order_area_id, :integer
    add_index :work_order_types, :work_order_area_id
  end
end
