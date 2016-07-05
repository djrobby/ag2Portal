class AddTypeToWorkOrderLabors < ActiveRecord::Migration
  def change
    add_column :work_order_labors, :work_order_type_id, :integer
    add_index :work_order_labors, :work_order_type_id
  end
end
