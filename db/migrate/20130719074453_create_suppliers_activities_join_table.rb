class CreateSuppliersActivitiesJoinTable < ActiveRecord::Migration
  def change
    create_table :suppliers_activities, id: false do |t|
      t.integer :supplier_id
      t.integer :activity_id
    end
    add_index :suppliers_activities, [:supplier_id, :activity_id]
  end
end
