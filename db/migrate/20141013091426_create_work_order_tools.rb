class CreateWorkOrderTools < ActiveRecord::Migration
  def change
    create_table :work_order_tools do |t|
      t.references :work_order
      t.references :tool
      t.decimal :minutes, :precision => 7, :scale => 2, :null => false, :default => '0'
      t.decimal :cost, :precision => 12, :scale => 4, :null => false, :default => '0'

      t.timestamps
    end
    add_index :work_order_tools, :work_order_id
    add_index :work_order_tools, :tool_id
  end
end
