class CreateWorkOrderSubcontractors < ActiveRecord::Migration
  def change
    create_table :work_order_subcontractors do |t|
      t.references :work_order
      t.references :supplier
      t.references :purchase_order
      t.decimal :enforcement_pct, :precision => 7, :scale => 2, :null => false, :default => '0'

      t.timestamps
    end
    add_index :work_order_subcontractors, :work_order_id
    add_index :work_order_subcontractors, :supplier_id
    add_index :work_order_subcontractors, :purchase_order_id
  end
end
