class CreateWorkOrderAreas < ActiveRecord::Migration
  def change
    create_table :work_order_areas do |t|
      t.string :name
      t.references :organization

      t.timestamps
    end
    add_index :work_order_areas, :organization_id
  end
end
