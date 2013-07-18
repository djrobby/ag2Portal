class CreateSuppliersActivities < ActiveRecord::Migration
  def change
    create_table :suppliers_activities do |t|
      t.references :supplier
      t.references :activity
      t.boolean :default

      t.timestamps
    end
    add_index :suppliers_activities, [:supplier_id, :activity_id]
  end
end
